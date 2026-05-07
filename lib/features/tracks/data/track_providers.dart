import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/course.dart';
import '../../../shared/models/teacher.dart';
import '../../admin/data/catalog_store.dart';
import '../../study_guides/data/pdf_manifest.dart';
import '../../study_guides/data/supabase_guides_service.dart';
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

/// All study guides visible to students, merged from three sources in
/// priority order (later sources win on id collisions):
///
/// 1. Local catalog seed + per-browser admin-portal additions (held in
///    `shared_preferences`).
/// 2. Bundled manifest entries from `assets/pdfs/manifest.json` (PDFs that
///    ship with the build).
/// 3. Supabase Postgres rows streamed in realtime — this is the
///    cross-device source of truth where admin-portal uploads land.
final allStudyGuidesProvider = Provider<List<StudyGuide>>((ref) {
  final catalog = ref.watch(studyGuidesProvider);
  final manifest = ref.watch(manifestStudyGuidesProvider);
  final remote = ref.watch(supabaseGuidesListProvider);
  final byId = <String, StudyGuide>{for (final g in catalog) g.id: g};
  for (final g in manifest) {
    byId[g.id] = g;
  }
  for (final g in remote) {
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
