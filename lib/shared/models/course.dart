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
    required this.trackId,
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
  final String trackId;
  final String? coverUrl;
  final String description;

  Course copyWith({
    String? id,
    String? title,
    String? teacherId,
    String? teacherName,
    String? subject,
    int? lessonsCount,
    bool? isLocked,
    String? trackId,
    String? coverUrl,
    String? description,
  }) => Course(
    id: id ?? this.id,
    title: title ?? this.title,
    teacherId: teacherId ?? this.teacherId,
    teacherName: teacherName ?? this.teacherName,
    subject: subject ?? this.subject,
    lessonsCount: lessonsCount ?? this.lessonsCount,
    isLocked: isLocked ?? this.isLocked,
    trackId: trackId ?? this.trackId,
    coverUrl: coverUrl ?? this.coverUrl,
    description: description ?? this.description,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'subject': subject,
    'lessonsCount': lessonsCount,
    'isLocked': isLocked,
    'trackId': trackId,
    'coverUrl': coverUrl,
    'description': description,
  };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as String,
    title: json['title'] as String,
    teacherId: json['teacherId'] as String,
    teacherName: json['teacherName'] as String,
    subject: json['subject'] as String,
    lessonsCount: json['lessonsCount'] as int,
    isLocked: json['isLocked'] as bool,
    trackId: json['trackId'] as String,
    coverUrl: json['coverUrl'] as String?,
    description: (json['description'] as String?) ?? '',
  );
}

/// A single lesson inside a course.
///
/// [bunnyVideoId] is the Bunny.net Stream video GUID. Once Cloud Functions
/// are in place the client passes this id to a callable function which
/// returns a short-lived signed URL. While the backend is deferred,
/// [previewVideoUrl] is used as a public MP4 stand-in so the player UX is
/// fully demoable.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.durationMinutes,
    this.isFreePreview = false,
    this.bunnyVideoId,
    this.previewVideoUrl,
    this.attachments = const [],
  });

  final String id;
  final String title;
  final int durationMinutes;
  final bool isFreePreview;
  final String? bunnyVideoId;
  final String? previewVideoUrl;
  final List<LessonAttachment> attachments;
}

/// A downloadable attachment (PDF, slides, worksheet) tied to a lesson.
class LessonAttachment {
  const LessonAttachment({
    required this.id,
    required this.title,
    required this.url,
    required this.kind,
    this.sizeBytes,
  });

  final String id;
  final String title;
  final String url;
  final AttachmentKind kind;
  final int? sizeBytes;
}

enum AttachmentKind {
  pdf,
  worksheet,
  slides,
  notes;

  String get arabicLabel => switch (this) {
    AttachmentKind.pdf => 'ملف PDF',
    AttachmentKind.worksheet => 'ورقة تمارين',
    AttachmentKind.slides => 'شرائح',
    AttachmentKind.notes => 'ملاحظات',
  };
}
