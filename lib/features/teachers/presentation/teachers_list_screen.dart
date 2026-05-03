import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/models/teacher.dart';
import '../../tracks/data/track_providers.dart';
import '../../tracks/domain/learning_track.dart';

/// Tab-level "المدرسون" screen.
///
/// Filters teachers by [selectedTrackProvider]. If no track is selected we
/// show a "اختر القسم" empty state with a button that drops the user back
/// onto the Hub tab.
class TeachersListScreen extends ConsumerWidget {
  const TeachersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final track = ref.watch(selectedTrackProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المدرسون')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TrackChips(
              selected: track,
              onSelected: (t) =>
                  ref.read(selectedTrackProvider.notifier).select(t),
            ),
            const SizedBox(height: 12),
            if (track == null)
              Expanded(
                child: _ChooseTrackEmptyState(
                  onChoose: () => context.goNamed(AppRoute.home),
                ),
              )
            else
              Expanded(
                child: _TeachersForTrack(track: track, theme: theme),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeachersForTrack extends ConsumerWidget {
  const _TeachersForTrack({required this.track, required this.theme});

  final LearningTrack track;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachers = ref.watch(teachersForTrackProvider(track));
    if (teachers.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد مدرسون في هذا القسم بعد',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: teachers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _TeacherListTile(teacher: teachers[i]),
    );
  }
}

class _TeacherListTile extends StatelessWidget {
  const _TeacherListTile({required this.teacher});

  final Teacher teacher;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoute.teacherProfileFromTab,
          pathParameters: {'id': teacher.id},
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  teacher.name.characters.first,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      teacher.subject,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${teacher.coursesCount} كورس',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${teacher.studentsCount} طالب',
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackChips extends StatelessWidget {
  const _TrackChips({required this.selected, required this.onSelected});

  final LearningTrack? selected;
  final ValueChanged<LearningTrack> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: LearningTrack.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = LearningTrack.values[i];
          final isSelected = t == selected;
          return ChoiceChip(
            avatar: Icon(t.icon, size: 18),
            label: Text(t.shortLabel),
            selected: isSelected,
            onSelected: (_) => onSelected(t),
          );
        },
      ),
    );
  }
}

class _ChooseTrackEmptyState extends StatelessWidget {
  const _ChooseTrackEmptyState({required this.onChoose});
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'اختر القسم أولاً',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'كل قسم له مدرسوه الخاصون. اختر قسماً لرؤية المدرسين.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onChoose,
              icon: const Icon(Icons.apps_rounded),
              label: const Text('انتقل إلى الأقسام'),
            ),
          ],
        ),
      ),
    );
  }
}
