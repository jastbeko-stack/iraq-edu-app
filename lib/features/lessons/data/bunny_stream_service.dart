import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves a playable URL for a lesson.
///
/// In production this should call a Cloud Function (e.g.
/// `getSignedLessonUrl({ courseId, lessonId })`) which:
/// 1. Verifies the caller's Firebase Auth UID has access to the course
///    (entitlements derived from coupon redemption + payment records).
/// 2. Generates a short-lived **token-authenticated** Bunny.net URL using
///    the Stream library's signing key (kept server-side).
/// 3. Returns the HLS manifest URL with the token query parameters.
///
/// The URL signing algorithm — for reference when writing the Cloud
/// Function — is:
///
/// ```
///   token_path = "/<video_guid>/playlist.m3u8"
///   expires    = unix_seconds + 60 * 60      // 1 hour
///   raw        = signing_key + token_path + expires
///   token      = base64url( sha256_bytes(raw) )
///   url        = "https://${cdn_hostname}${token_path}"
///                "?token=${token}&expires=${expires}"
/// ```
///
/// Source: https://docs.bunny.net/docs/stream-embedding-videos-token-authentication
///
/// **The signing key MUST stay on the server.** Any client-side
/// implementation can be ripped out of the bundle, defeating the
/// "Media Segments" / token-auth protection that Bunny offers.
///
/// While Cloud Functions are deferred, [resolvePlaybackUrl] returns the
/// lesson's `previewVideoUrl` (a public MP4) so the player UX can be
/// exercised end-to-end on the live preview.
abstract class BunnyStreamService {
  /// Returns a URL the player can hand to `video_player`.
  Future<Uri> resolvePlaybackUrl({
    required String courseId,
    required String lessonId,
    String? bunnyVideoId,
    String? fallbackPreviewUrl,
  });
}

/// Demo implementation that just returns the public preview URL.
///
/// Replace with a Cloud-Function-backed implementation by overriding
/// [bunnyStreamServiceProvider] once the backend lands. Consumers do not
/// need to change.
class DemoBunnyStreamService implements BunnyStreamService {
  const DemoBunnyStreamService();

  @override
  Future<Uri> resolvePlaybackUrl({
    required String courseId,
    required String lessonId,
    String? bunnyVideoId,
    String? fallbackPreviewUrl,
  }) async {
    final src = fallbackPreviewUrl ?? _publicSampleMp4;
    return Uri.parse(src);
  }

  /// Flutter's own public sample MP4 — small, CORS-enabled, plays in
  /// iOS Safari, Android, and Chrome. Replace with a real signed Bunny
  /// CDN URL once Cloud Functions are wired.
  static const _publicSampleMp4 =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
}

/// DI hook so widgets can `ref.watch(bunnyStreamServiceProvider)` without
/// caring whether they're talking to the demo impl or the real one.
final bunnyStreamServiceProvider = Provider<BunnyStreamService>((ref) {
  return const DemoBunnyStreamService();
});
