import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/security/screen_protection.dart';
import '../../data/bunny_stream_service.dart';

/// Professional video player for a lesson.
///
/// - Wraps `video_player` with `chewie` so we get the full Material control
///   bar (scrubber, fullscreen, mute, settings menu) for free.
/// - Hardcoded **playback speeds 0.5× → 2.0×** because students always
///   want this.
/// - Forces a 16:9 aspect ratio while loading so the surrounding layout
///   doesn't jump when the first frame arrives.
class LessonVideoPlayer extends ConsumerStatefulWidget {
  const LessonVideoPlayer({
    required this.courseId,
    required this.lessonId,
    required this.lessonTitle,
    this.bunnyVideoId,
    this.previewVideoUrl,
    super.key,
  });

  final String courseId;
  final String lessonId;
  final String lessonTitle;
  final String? bunnyVideoId;
  final String? previewVideoUrl;

  @override
  ConsumerState<LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends ConsumerState<LessonVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  Object? _error;

  /// True while the iOS native side reports the screen is being captured
  /// (recorded or AirPlay-mirrored). We blur the video to discourage
  /// recording — Apple does not give us a way to *block* it.
  bool _iosCapturing = false;
  VoidCallback? _iosCaptureSubscription;

  @override
  void initState() {
    super.initState();
    _iosCaptureSubscription = ScreenProtection.listenIos(
      onCaptureChanged: (isCapturing) {
        if (mounted) setState(() => _iosCapturing = isCapturing);
        if (isCapturing) _videoController?.pause();
      },
    );
    _bootstrap();
  }

  @override
  void didUpdateWidget(covariant LessonVideoPlayer old) {
    super.didUpdateWidget(old);
    if (old.lessonId != widget.lessonId) {
      _disposeControllers();
      _bootstrap();
    }
  }

  Future<void> _bootstrap() async {
    try {
      final service = ref.read(bunnyStreamServiceProvider);
      final uri = await service.resolvePlaybackUrl(
        courseId: widget.courseId,
        lessonId: widget.lessonId,
        bunnyVideoId: widget.bunnyVideoId,
        fallbackPreviewUrl: widget.previewVideoUrl,
      );

      final video = VideoPlayerController.networkUrl(uri);
      await video.initialize();
      if (!mounted) {
        await video.dispose();
        return;
      }

      final chewie = ChewieController(
        videoPlayerController: video,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0],
        aspectRatio: video.value.aspectRatio == 0
            ? 16 / 9
            : video.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).colorScheme.primary,
          handleColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
      );

      setState(() {
        _videoController = video;
        _chewieController = chewie;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  @override
  void dispose() {
    _iosCaptureSubscription?.call();
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            switch ((_error, _chewieController)) {
              (final err?, _) => _ErrorState(error: err),
              (_, final chewie?) => Chewie(controller: chewie),
              _ => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            },
            if (_iosCapturing) const _RecordingBlocker(),
          ],
        ),
      ),
    );
  }
}

/// Full-screen overlay shown while iOS reports the screen is being
/// captured. Anything *behind* this widget gets effectively hidden in
/// the recording — we cannot prevent the capture, only what shows up.
class _RecordingBlocker extends StatelessWidget {
  const _RecordingBlocker();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              Text(
                'تم إيقاف التشغيل أثناء التسجيل',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'تسجيل الشاشة غير مسموح به لحماية محتوى الكورس.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 36),
            const SizedBox(height: 8),
            Text(
              'تعذر تشغيل الفيديو',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '$error',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
