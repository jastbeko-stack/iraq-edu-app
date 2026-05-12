import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../announcements/data/announcements_service.dart';
import '../../announcements/domain/announcement.dart';
import '../../auth/data/auth_controller.dart';
import '../../tracks/data/track_providers.dart';
import '../../tracks/domain/learning_track.dart';

/// Three-category landing screen ("Hub").
///
/// Acts as the public landing page: a curved royal-blue header carries the
/// brand identity, a quick-actions strip surfaces the most common
/// destinations, and the three track cards drive selection of a learning
/// track. Once the user picks a track, [HomeScreen] swaps in
/// [CategoryHomeScreen].
class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Match the curved blue header behind the status bar so the system
      // overlay icons stay readable on both platforms.
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _HubHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Consumer(
                builder: (context, ref, _) {
                  // Only show announcements to signed-in students. Casual
                  // visitors browsing the public landing page should not see
                  // internal communications.
                  if (!ref.watch(isSignedInProvider)) {
                    return const SizedBox.shrink();
                  }
                  final a = ref.watch(activeAnnouncementProvider);
                  if (a == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _AnnouncementBanner(announcement: a),
                  );
                },
              ),
            ),
            const _QuickActionsStrip(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'اختر القسم',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'كل قسم يحتوي على مدرسيه، كورساته، وملازمه الخاصة.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (final track in LearningTrack.values) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _TrackCard(
                  track: track,
                  onTap: () =>
                      ref.read(selectedTrackProvider.notifier).select(track),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Center(
              child: Text(
                '٢٠٢٥ — جميع الحقوق محفوظة',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Curved royal-blue header carrying the brand identity, profile/notification
/// affordances, and a search field that visually overlaps the bottom edge.
class _HubHeader extends ConsumerWidget {
  const _HubHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.of(context).padding.top;
    // Reserve enough space for the curved header + the overlapping search
    // field that sits half-outside the bottom edge. The header itself grows
    // to cover the status bar inset on mobile.
    final headerHeight = 160 + topInset;
    return SizedBox(
      height: headerHeight + 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Header background (gradient + curved bottom).
          Container(
            height: headerHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, topInset + 14, 16, 0),
              child: Row(
                children: [
                  // Brand cluster — logo + title sit at the start of the
                  // header (right-side in RTL) so they read as a unified
                  // brand block, matching the reference design.
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'منصة المهندس',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'التعليمية',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _NotificationBell(),
                  const SizedBox(width: 10),
                  // Profile avatar (signed-in users see their avatar; others
                  // see a neutral icon).
                  Consumer(
                    builder: (context, ref, _) {
                      final signedIn = ref.watch(isSignedInProvider);
                      return InkWell(
                        borderRadius: BorderRadius.circular(99),
                        onTap: () => context.goNamed(AppRoute.profile),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: Icon(
                            signedIn
                                ? Icons.person
                                : Icons.person_outline_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Search field, overlapping the bottom edge of the header.
          PositionedDirectional(
            start: 16,
            end: 16,
            bottom: 0,
            child: Material(
              elevation: 6,
              shadowColor: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsetsDirectional.only(start: 6, end: 14),
                child: Row(
                  children: [
                    // Filter pill on the leading side (matches the reference
                    // design, even though search itself is a no-op for now).
                    Container(
                      margin: const EdgeInsets.all(6),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          hintText: 'ابحث عن كورس، ملزمة، أو مدرّس…',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification bell with an unread indicator dot.
class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
        PositionedDirectional(
          top: 8,
          end: 8,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Grid of 4 quick-action tiles surfaced just under the header.
class _QuickActionsStrip extends StatelessWidget {
  const _QuickActionsStrip();

  @override
  Widget build(BuildContext context) {
    final items = <_QuickAction>[
      _QuickAction(
        icon: Icons.menu_book_outlined,
        label: 'الكورسات',
        color: AppColors.primary,
        onTap: () {
          // Navigate inside the home tab; the user picks a track first.
        },
      ),
      _QuickAction(
        icon: Icons.collections_bookmark_outlined,
        label: 'الملازم',
        color: AppColors.secondary,
        onTap: () => GoRouter.of(context).goNamed(AppRoute.studyGuides),
      ),
      _QuickAction(
        icon: Icons.person_outline_rounded,
        label: 'المدرّسون',
        color: const Color(0xFF7C3AED),
        onTap: () => GoRouter.of(context).goNamed(AppRoute.teachers),
      ),
      _QuickAction(
        icon: Icons.account_circle_outlined,
        label: 'حسابي',
        color: AppColors.accent,
        onTap: () => GoRouter.of(context).goNamed(AppRoute.profile),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(child: _QuickActionTile(item: items[i])),
            if (i != items.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.item});
  final _QuickAction item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackCard extends ConsumerWidget {
  const _TrackCard({required this.track, required this.onTap});

  final LearningTrack track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = track.gradientColors(theme.colorScheme);
    final teachers = ref.watch(teachersForTrackProvider(track));
    final courses = ref.watch(coursesForTrackProvider(track));
    final guides = ref.watch(guidesForTrackProvider(track));

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Colored thumbnail (uses the track's existing gradient so
              // each track remains visually distinct).
              Container(
                width: 72,
                height: 84,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(track.icon, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _MetaChip(
                          icon: Icons.person_outline,
                          label: '${teachers.length} مدرس',
                        ),
                        _MetaChip(
                          icon: Icons.menu_book_outlined,
                          label: '${courses.length} كورس',
                        ),
                        _MetaChip(
                          icon: Icons.collections_bookmark_outlined,
                          label: '${guides.length} ملزمة',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_left_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementBanner extends StatelessWidget {
  const _AnnouncementBanner({required this.announcement});
  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.95),
            AppColors.primary.withValues(alpha: 0.95),
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
