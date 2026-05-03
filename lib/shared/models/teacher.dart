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
    required this.trackId,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String subject;
  final String bio;
  final int coursesCount;
  final int studentsCount;

  /// Stable id of the [LearningTrack] this teacher belongs to
  /// (`preparatory`, `engineering`, `medical`). Stored as a raw string so
  /// the model stays a plain DTO with no Flutter dependency — the lookup
  /// happens at the presentation layer via `LearningTrack.fromId`.
  final String trackId;
  final String? avatarUrl;

  Teacher copyWith({
    String? id,
    String? name,
    String? subject,
    String? bio,
    int? coursesCount,
    int? studentsCount,
    String? trackId,
    String? avatarUrl,
  }) => Teacher(
    id: id ?? this.id,
    name: name ?? this.name,
    subject: subject ?? this.subject,
    bio: bio ?? this.bio,
    coursesCount: coursesCount ?? this.coursesCount,
    studentsCount: studentsCount ?? this.studentsCount,
    trackId: trackId ?? this.trackId,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subject': subject,
    'bio': bio,
    'coursesCount': coursesCount,
    'studentsCount': studentsCount,
    'trackId': trackId,
    'avatarUrl': avatarUrl,
  };

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
    id: json['id'] as String,
    name: json['name'] as String,
    subject: json['subject'] as String,
    bio: json['bio'] as String,
    coursesCount: json['coursesCount'] as int,
    studentsCount: json['studentsCount'] as int,
    trackId: json['trackId'] as String,
    avatarUrl: json['avatarUrl'] as String?,
  );
}
