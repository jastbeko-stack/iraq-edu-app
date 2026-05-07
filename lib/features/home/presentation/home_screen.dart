import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tracks/data/track_providers.dart';
import '../../tracks/domain/learning_track.dart';
import 'category_home_screen.dart';
import 'hub_screen.dart';

/// Top-level Home tab.
///
/// Acts as a switcher: when no [LearningTrack] is selected the user sees the
/// [HubScreen] (three big category cards). Once a track is picked the same
/// tab renders [CategoryHomeScreen] scoped to that track. A "categories"
/// action in the AppBar of [CategoryHomeScreen] clears the selection and
/// returns the user to the Hub.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(selectedTrackProvider);
    if (track == null) return const HubScreen();
    return CategoryHomeScreen(track: track);
  }
}
