/// Lightweight model for a teacher / instructor.
///
/// Real data will come from Firestore (`teachers` collection). This local
/// model lets the UI render with sample data while the backend is being wired.
class Teacher {
  const Teacher({
    required this.id,
    required this.name,
    required this.subject,
    required this.bio,
    required this.coursesCount,
    required this.studentsCount,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String subject;
  final String bio;
  final int coursesCount;
  final int studentsCount;
  final String? avatarUrl;
}
