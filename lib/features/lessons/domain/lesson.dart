/// A single video lesson belonging to a course.
///
/// Persisted in Supabase Postgres (`public.lessons`) so every device
/// (admin + students) sees the same lessons in realtime.
class Lesson {
  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.videoUrl,
    this.description = '',
    this.orderIndex = 0,
    this.isFreePreview = false,
  });

  final String id;
  final String courseId;
  final String title;
  final String description;
  final String videoUrl;
  final int orderIndex;
  final bool isFreePreview;

  Lesson copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    String? videoUrl,
    int? orderIndex,
    bool? isFreePreview,
  }) => Lesson(
    id: id ?? this.id,
    courseId: courseId ?? this.courseId,
    title: title ?? this.title,
    description: description ?? this.description,
    videoUrl: videoUrl ?? this.videoUrl,
    orderIndex: orderIndex ?? this.orderIndex,
    isFreePreview: isFreePreview ?? this.isFreePreview,
  );
}
