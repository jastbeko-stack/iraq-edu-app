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
            const SizedBox(height: 8),
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
    // A single curved blue panel that hosts both the brand row and the
    // search bar. No overlap below the header — everything is contained
    // inside the gradient surface.
    return Container(
      decoration: const BoxDecoration(
        // Solid primary colour at the very top edge so the browser/OS
        // chrome (themed to AppColors.primary via index.html) blends in
        // seamlessly. The subtle vertical gradient adds depth without
        // changing the colour at the very top.
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Single-row brand strip: logo + title on the leading edge,
          // bell + profile avatar on the trailing edge.
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
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
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'منصة المهندس',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'التعليمية',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _NotificationBell(),
              const SizedBox(width: 8),
              Consumer(
                builder: (context, ref, _) {
                  final signedIn = ref.watch(isSignedInProvider);
                  return InkWell(
                    borderRadius: BorderRadius.circular(99),
                    onTap: () => context.goNamed(AppRoute.profile),
                    child: CircleAvatar(
                      radius: 20,
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
          const SizedBox(height: 14),
          // White search bar — lives INSIDE the blue header (no overlap)
          // so the whole block reads as one cohesive piece.
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsetsDirectional.only(start: 6, end: 14),
            child: Row(
                children: [
                  // Filter pill on the leading side.
                  Container(
                    margin: const EdgeInsets.all(6),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
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
                          vertical: 12,
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
        ],
      ),
    );
  }
}

/// Notification bell with an unread count badge.
///
/// Painted directly on the header (no background pill) so the bell matches
/// the reference design's clean look.
class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Text(
                '٣',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
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
        emoji: '🏆',
        label: 'نتائج الطلاب',
        color: const Color(0xFFFFA000),
        gradient: const [Color(0xFFFFD54F), Color(0xFFFF8F00)],
        onTap: () => GoRouter.of(context).goNamed(AppRoute.results),
      ),
      _QuickAction(
        emoji: '❓',
        label: 'اسئلة الطلاب',
        color: const Color(0xFF1FAFA8),
        gradient: const [Color(0xFF4DD0CB), Color(0xFF00897B)],
        onTap: () => GoRouter.of(context).goNamed(AppRoute.studentQuestions),
      ),
      _QuickAction(
        emoji: '💎',
        label: 'محاضراتي المدفوعة',
        color: AppColors.primary,
        gradient: const [Color(0xFF4F8EE0), Color(0xFF143F76)],
        onTap: () => GoRouter.of(context).goNamed(AppRoute.paidLectures),
      ),
      _QuickAction(
        emoji: '▶️',
        label: 'المحاضرات المجانية',
        color: const Color(0xFF22A06B),
        gradient: const [Color(0xFF6FCF97), Color(0xFF1F8A50)],
        onTap: () => GoRouter.of(context).goNamed(AppRoute.freeLectures),
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
    required this.emoji,
    required this.label,
    required this.gradient,
    required this.color,
    required this.onTap,
  });
  final String emoji;
  final String label;
  final Color color;
  final List<Color> gradient;
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                // Force every emoji to occupy the same visual area so the
                // logos line up at a consistent size regardless of the
                // emoji's intrinsic metrics (e.g. ❓ vs 🏆).
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: Text(
                      item.emoji,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
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
