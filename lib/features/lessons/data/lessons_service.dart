import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../study_guides/data/supabase_guides_service.dart'
    show supabaseClientProvider;
import '../domain/lesson.dart';

/// Supabase-backed CRUD + Storage upload for [Lesson]s.
///
/// All admin uploads (video bytes -> `videos` bucket) and metadata writes
/// (`public.lessons`) flow through here, and student devices subscribe to the
/// realtime stream so newly published lessons appear without a refresh.
class LessonsService {
  LessonsService(this._client);

  final SupabaseClient _client;

  static const String _bucket = 'videos';
  static const String _table = 'lessons';

  /// Uploads a video file to the `videos` bucket under
  /// `course-<courseId>/lesson-<lessonId>.<ext>` and returns its public URL.
  Future<String> uploadVideo({
    required String courseId,
    required String lessonId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final ext = fileExtension.toLowerCase().replaceAll('.', '');
    final objectPath = 'course-$courseId/lesson-$lessonId.$ext';
    await _client.storage
        .from(_bucket)
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(
            contentType: _mimeForExtension(ext),
            upsert: true,
          ),
        );
    return _client.storage.from(_bucket).getPublicUrl(objectPath);
  }

  /// Best-effort deletion of the storage object referenced by [url]. Silently
  /// no-ops for URLs that aren't in the `videos` bucket.
  Future<void> deleteVideoByUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final marker = '/storage/v1/object/public/$_bucket/';
    final i = url.indexOf(marker);
    if (i == -1) return;
    final objectPath = url.substring(i + marker.length);
    if (objectPath.isEmpty) return;
    try {
      await _client.storage.from(_bucket).remove([objectPath]);
    } catch (_) {
      // Object already gone or blocked by RLS — let the row delete proceed.
    }
  }

  Future<Lesson> insertLesson(Lesson lesson) async {
    final row = await _client
        .from(_table)
        .insert(_toRow(lesson))
        .select()
        .single();
    return _fromRow(row);
  }

  Future<void> updateLesson(Lesson lesson) async {
    await _client.from(_table).update(_toRow(lesson)).eq('id', lesson.id);
  }

  Future<void> deleteLesson(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  Stream<List<Lesson>> streamLessons() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('order_index')
        .map((rows) => rows.map(_fromRow).toList());
  }

  Map<String, dynamic> _toRow(Lesson l) => {
    'id': l.id,
    'course_id': l.courseId,
    'title': l.title,
    'description': l.description,
    'video_url': l.videoUrl,
    'order_index': l.orderIndex,
    'is_free_preview': l.isFreePreview,
  };

  Lesson _fromRow(Map<String, dynamic> row) => Lesson(
    id: row['id'] as String,
    courseId: (row['course_id'] as String?) ?? '',
    title: (row['title'] as String?) ?? '',
    description: (row['description'] as String?) ?? '',
    videoUrl: (row['video_url'] as String?) ?? '',
    orderIndex: (row['order_index'] as num?)?.toInt() ?? 0,
    isFreePreview: (row['is_free_preview'] as bool?) ?? false,
  );

  String _mimeForExtension(String ext) {
    switch (ext) {
      case 'mp4':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      case 'mov':
        return 'video/quicktime';
      case 'mkv':
        return 'video/x-matroska';
      default:
        return 'video/mp4';
    }
  }
}

final lessonsServiceProvider = Provider<LessonsService>(
  (ref) => LessonsService(ref.watch(supabaseClientProvider)),
);

/// Realtime stream of every lesson in the database. UI layers filter by
/// `courseId` locally — keeping a single stream means lessons load once for
/// the entire app and updates fan out everywhere.
final lessonsStreamProvider = StreamProvider<List<Lesson>>((ref) {
  return ref.watch(lessonsServiceProvider).streamLessons();
});

/// Synchronous list projection of [lessonsStreamProvider]. Yields `[]` while
/// the first snapshot is loading.
final lessonsListProvider = Provider<List<Lesson>>((ref) {
  return ref
      .watch(lessonsStreamProvider)
      .maybeWhen(data: (xs) => xs, orElse: () => const []);
});

/// Lessons for a single course, ordered by `order_index`.
final lessonsForCourseProvider = Provider.family<List<Lesson>, String>((
  ref,
  courseId,
) {
  return ref.watch(lessonsListProvider).where((l) => l.courseId == courseId).toList()
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
});
