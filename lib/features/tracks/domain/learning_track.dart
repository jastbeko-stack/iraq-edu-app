import 'package:flutter/material.dart';

/// One of the three top-level "tracks" the platform is organized around.
///
/// Tracks live above subjects: a track contains many teachers, courses,
/// and study guides; a single subject (e.g. "الرياضيات") may exist
/// independently in two tracks (preparatory math vs. engineering math).
enum LearningTrack {
  /// السادس الإعدادي (preparatory / 6th-grade scientific).
  preparatory(id: 'preparatory'),

  /// الكليات الهندسية (engineering colleges).
  engineering(id: 'engineering'),

  /// الكليات الطبية (medical colleges).
  medical(id: 'medical');

  const LearningTrack({required this.id});

  final String id;

  /// Lookup by stable id used in URLs / coupon prefixes / sample data.
  static LearningTrack? fromId(String id) {
    for (final t in LearningTrack.values) {
      if (t.id == id) return t;
    }
    return null;
  }

  String get label => switch (this) {
    LearningTrack.preparatory => 'الدراسة الإعدادية',
    LearningTrack.engineering => 'الكليات الهندسية',
    LearningTrack.medical => 'الكليات الطبية',
  };

  String get shortLabel => switch (this) {
    LearningTrack.preparatory => 'الإعدادية',
    LearningTrack.engineering => 'الهندسية',
    LearningTrack.medical => 'الطبية',
  };

  String get tagline => switch (this) {
    LearningTrack.preparatory => 'السادس العلمي — رياضيات، فيزياء، أحياء',
    LearningTrack.engineering =>
      'كليات الهندسة المدنية، الميكانيك، الكهرباء، الإلكترونيات',
    LearningTrack.medical => 'كليات الطب، طب الأسنان، الصيدلة',
  };

  /// Icon is intentionally outline+filled material — they are
  /// instantly recognizable for these three contexts.
  IconData get icon => switch (this) {
    LearningTrack.preparatory => Icons.school_rounded,
    LearningTrack.engineering => Icons.engineering_rounded,
    LearningTrack.medical => Icons.medical_services_rounded,
  };

  /// Per-track gradient used in hub cards, category headers, and
  /// study-guide chips so each track has a distinct visual identity.
  List<Color> gradientColors(ColorScheme scheme) => switch (this) {
    LearningTrack.preparatory => [
      const Color(0xFFC8102E),
      const Color(0xFFFF6B6B),
    ],
    LearningTrack.engineering => [
      const Color(0xFF1565C0),
      const Color(0xFF42A5F5),
    ],
    LearningTrack.medical => [const Color(0xFF00695C), const Color(0xFF26A69A)],
  };
}
