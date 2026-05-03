import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/course.dart';
import '../../../shared/models/teacher.dart';
import '../../admin/data/catalog_store.dart';
import '../../study_guides/data/pdf_manifest.dart';
import '../../study_guides/domain/study_guide.dart';
import '../domain/learning_track.dart';

class SelectedTrackController extends StateNotifier<LearningTrack?> {
  SelectedTrackController() : super(null);
  void select(LearningTrack track) => state = track;
  void clear() => state = null;
}

final selectedTrackProvider =
    StateNotifierProvider<SelectedTrackController, LearningTrack?>(
      (_) => SelectedTrackController(),
    );

final teachersForTrackProvider = Provider.family<List<Teacher>, LearningTrack>(
  (ref, track) =>
      ref.watch(teachersProvider).where((t) => t.trackId == track.id).toList(),
);

final coursesForTrackProvider = Provider.family<List<Course>, LearningTrack>(
  (ref, track) =>
      ref.watch(coursesProvider).where((c) => c.trackId == track.id).toList(),
);

/// All study guides visible to students: catalog (seed + admin-portal
/// additions persisted in shared_preferences) merged with bundled manifest
/// entries (`assets/pdfs/manifest.json`). Manifest entries win on id
/// collisions because they ship with a real PDF binary.
final allStudyGuidesProvider = Provider<List<StudyGuide>>((ref) {
  final catalog = ref.watch(studyGuidesProvider);
  final manifest = ref.watch(manifestStudyGuidesProvider);
  if (manifest.isEmpty) return catalog;
  final byId = <String, StudyGuide>{for (final g in catalog) g.id: g};
  for (final g in manifest) {
    byId[g.id] = g;
  }
  return byId.values.toList(growable: false);
});

final guidesForTrackProvider = Provider.family<List<StudyGuide>, LearningTrack>(
  (ref, track) => ref
      .watch(allStudyGuidesProvider)
      .where((g) => g.trackId == track.id)
      .toList(),
);
