/// Lightweight model for a course.
///
/// Real data will come from Firestore (`courses` collection). Lessons are
/// modeled separately so a course can hold many lessons.
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    required this.lessonsCount,
    required this.isLocked,
    this.coverUrl,
    this.description = '',
  });

  final String id;
  final String title;
  final String teacherId;
  final String teacherName;
  final String subject;
  final int lessonsCount;
  final bool isLocked;
  final String? coverUrl;
  final String description;
}

/// A single lesson inside a course.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.durationMinutes,
    this.isFreePreview = false,
  });

  final String id;
  final String title;
  final int durationMinutes;
  final bool isFreePreview;
}
