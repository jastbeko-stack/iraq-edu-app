import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../tracks/data/track_providers.dart';
import '../../tracks/domain/learning_track.dart';
import '../data/study_guide_repository.dart';
import '../domain/study_guide.dart';
import 'widgets/study_guide_coupon_sheet.dart';

/// Storefront for the الملازم (Study Guides) section.
///
/// Layout:
/// - AppBar with a "تفعيل ملزمة" action that opens [StudyGuideCouponSheet]
/// - Track selector chips (الإعدادية / الهندسية / الطبية) — drives the
///   [selectedTrackProvider] and is shared with the Home + Teachers tabs
/// - Subject filter row scoped to the current track's available subjects
/// - Vertical list of [_GuideCard]s reactively bound to unlock state
class StudyGuidesStoreScreen extends ConsumerStatefulWidget {
  const StudyGuidesStoreScreen({super.key});

  @override
  ConsumerState<StudyGuidesStoreScreen> createState() =>
      _StudyGuidesStoreScreenState();
}

class _StudyGuidesStoreScreenState
    extends ConsumerState<StudyGuidesStoreScreen> {
  /// 'الكل' means the subject filter is off; otherwise it must match a
  /// `subject` value on a [StudyGuide] in the current track.
  String _selectedSubject = 'الكل';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = ref.watch(unlockedGuidesProvider);
    final track = ref.watch(selectedTrackProvider);

    final guidesInTrack = track == null
        ? const <StudyGuide>[]
        : ref.watch(guidesForTrackProvider(track));

    // Subjects available within this track (deduped, with 'الكل' at the
    // start so the user can clear the sub-filter).
    final subjects = <String>[
      'الكل',
      ...{for (final g in guidesInTrack) g.subject},
    ];

    final filtered = _selectedSubject == 'الكل'
        ? guidesInTrack
        : guidesInTrack.where((g) => g.subject == _selectedSubject).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملازم'),
        actions: [
          IconButton(
            tooltip: 'تفعيل كوبون',
            icon: const Icon(Icons.confirmation_number_outlined),
            onPressed: () => StudyGuideCouponSheet.show(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _StoreHeaderCard(
            unlockedCount: unlocked.length,
            totalGuidesInTrack: guidesInTrack.length,
            totalAllGuides: ref.watch(allStudyGuidesProvider).length,
            track: track,
          ),
          const SizedBox(height: 16),
          _TrackChips(
            selected: track,
            onSelected: (t) {
              ref.read(selectedTrackProvider.notifier).select(t);
              setState(() => _selectedSubject = 'الكل');
            },
          ),
          if (track == null) ...[
            const SizedBox(height: 24),
            _ChooseTrackEmptyState(
              onChoose: () => context.goNamed(AppRoute.home),
            ),
          ] else ...[
            const SizedBox(height: 12),
            // Subject sub-filter
            if (subjects.length > 2)
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: subjects.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final s = subjects[i];
                    final selected = s == _selectedSubject;
                    return ChoiceChip(
                      label: Text(s),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedSubject = s),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'لا توجد ملازم في هذا الموضوع بعد',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              for (final g in filtered) ...[
                _GuideCard(guide: g),
                const SizedBox(height: 10),
              ],
          ],
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 48,
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
            'الملازم مرتبة حسب القسم: الإعدادية، الهندسية، الطبية.',
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
    );
  }
}

class _StoreHeaderCard extends StatelessWidget {
  const _StoreHeaderCard({
    required this.unlockedCount,
    required this.totalGuidesInTrack,
    required this.totalAllGuides,
    required this.track,
  });

  final int unlockedCount;
  final int totalGuidesInTrack;
  final int totalAllGuides;
  final LearningTrack? track;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = track == null
        ? [scheme.primary, scheme.tertiary]
        : track!.gradientColors(scheme);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'متجر الملازم',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (track != null) ...[
                const SizedBox(width: 6),
                Text(
                  '— ${track!.shortLabel}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ملازم وملخصات وأسئلة وزارية مدفوعة، مرتبة حسب القسم. '
            'فعّل أي ملزمة بكود يوزّع من المدرس.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Pill(icon: Icons.lock_open, label: '$unlockedCount مفعّلة'),
              const SizedBox(width: 8),
              _Pill(
                icon: Icons.collections_bookmark_outlined,
                label: track == null
                    ? '$totalAllGuides ملزمة بالمجموع'
                    : '$totalGuidesInTrack ملزمة في القسم',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends ConsumerWidget {
  const _GuideCard({required this.guide});
  final StudyGuide guide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unlocked = ref.watch(isGuideUnlockedProvider(guide.id));
    final available = !guide.isLocked || unlocked;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoute.studyGuideDetails,
          pathParameters: {'id': guide.id},
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 84,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guide.author,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Tag(icon: Icons.book, label: guide.subject),
                        _Tag(
                          icon: Icons.menu_book,
                          label: '${guide.pageCount} صفحة',
                        ),
                        _Tag(
                          icon: Icons.attach_file,
                          label: _humanSize(guide.sizeBytes),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (available)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_open,
                                  size: 14,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'مفعّلة',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            '${guide.priceIqd.toString()} د.ع',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        const Spacer(),
                        Icon(
                          available ? Icons.download : Icons.lock,
                          size: 18,
                          color: available
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

String _humanSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
