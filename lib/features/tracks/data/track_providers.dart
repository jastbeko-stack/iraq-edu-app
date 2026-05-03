import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/course.dart';
import '../../../shared/models/teacher.dart';
import '../../admin/data/catalog_store.dart';
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

final guidesForTrackProvider = Provider.family<List<StudyGuide>, LearningTrack>(
  (ref, track) => ref
      .watch(studyGuidesProvider)
      .where((g) => g.trackId == track.id)
      .toList(),
);
