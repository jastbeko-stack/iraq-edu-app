import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/sample_data.dart';
import '../../admin/data/catalog_store.dart';
import '../../coupons/data/coupon_repository.dart';
import '../data/lessons_service.dart';
import 'widgets/lesson_attachments_list.dart';
import 'widgets/lesson_video_player.dart';

/// Full lesson view: video on top, then lesson title / metadata, then
/// attachments list.
///
/// Access rules:
/// - Free-preview lessons play for everyone.
/// - All other lessons require the parent course to be unlocked (via a
///   coupon redemption today, via Cloud Function entitlements later).
class LessonPlayerScreen extends ConsumerWidget {
  const LessonPlayerScreen({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final course = ref.watch(courseByIdProvider(courseId));
    // Newly-uploaded lessons (admin portal -> Supabase) take precedence over
    // the sample-data lessons so admins can replace or add to the bundled
    // catalog without code changes.
    final remoteLessons = ref.watch(lessonsForCourseProvider(courseId));
    final remote = remoteLessons.where((l) => l.id == lessonId).firstOrNull;
    final localLessons = SampleData.lessonsForCourse(courseId);
    final local = localLessons.where((l) => l.id == lessonId).firstOrNull;

    if (course == null || (remote == null && local == null)) {
      return Scaffold(
        appBar: AppBar(title: const Text('الدرس')),
        body: const Center(child: Text('الدرس غير موجود')),
      );
    }

    final lessonTitle = remote?.title ?? local!.title;
    final isFreePreview = remote?.isFreePreview ?? local!.isFreePreview;
    final attachments = local?.attachments ?? const [];
    final durationMinutes = local?.durationMinutes ?? 0;

    final unlocked = ref.watch(isCourseUnlockedProvider(course.id));
    final hasAccess = isFreePreview || !course.isLocked || unlocked;

    return Scaffold(
      appBar: AppBar(title: Text(lessonTitle)),
      body: !hasAccess
          ? _LockedLesson(courseTitle: course.title)
          : SafeArea(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  LessonVideoPlayer(
                    courseId: course.id,
                    lessonId: lessonId,
                    lessonTitle: lessonTitle,
                    bunnyVideoId: local?.bunnyVideoId,
                    previewVideoUrl:
                        remote?.videoUrl ?? local?.previewVideoUrl,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lessonTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (remote?.description.isNotEmpty == true) ...[
                          const SizedBox(height: 6),
                          Text(
                            remote!.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (durationMinutes > 0) ...[
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$durationMinutes دقيقة',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(width: 16),
                            ],
                            Icon(
                              Icons.menu_book,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                course.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (attachments.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            'مرفقات الدرس',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${attachments.length})',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      child: LessonAttachmentsList(attachments: attachments),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _LockedLesson extends StatelessWidget {
  const _LockedLesson({required this.courseTitle});
  final String courseTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'هذا الدرس مقفل',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'كورس "$courseTitle" يحتاج إلى تفعيل بكوبون أو اشتراك.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('العودة إلى الكورس'),
            ),
          ],
        ),
      ),
    );
  }
}
