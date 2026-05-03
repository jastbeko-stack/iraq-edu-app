import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/models/course.dart';
import '../../../shared/models/teacher.dart';
import '../../coupons/data/coupon_repository.dart';
import '../../tracks/data/track_providers.dart';
import '../../tracks/domain/learning_track.dart';

/// Per-track home: welcome banner, featured teachers carousel, courses list.
///
/// Reads its data from [teachersForTrackProvider] / [coursesForTrackProvider]
/// so adding a track in the data layer is enough to make a fully-rendered
/// home for it.
class CategoryHomeScreen extends ConsumerWidget {
  const CategoryHomeScreen({required this.track, super.key});

  final LearningTrack track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final teachers = ref.watch(teachersForTrackProvider(track));
    final courses = ref.watch(coursesForTrackProvider(track));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(track.icon, size: 22),
            const SizedBox(width: 8),
            Flexible(child: Text(track.label, overflow: TextOverflow.ellipsis)),
          ],
        ),
        leading: IconButton(
          tooltip: 'الأقسام',
          icon: const Icon(Icons.apps_rounded),
          onPressed: () => ref.read(selectedTrackProvider.notifier).clear(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _CategoryBanner(track: track),
          const SizedBox(height: 24),
          _SectionHeader(title: 'المدرسون المميزون', onViewAll: () {}),
          if (teachers.isEmpty)
            _EmptyState(
              icon: Icons.person_outline,
              text: 'لا يوجد مدرسون في هذا القسم بعد',
            )
          else
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                itemCount: teachers.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _TeacherCard(
                  teacher: teachers[i],
                  onTap: () => context.pushNamed(
                    AppRoute.teacherProfile,
                    pathParameters: {'id': teachers[i].id},
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'الكورسات المميزة', onViewAll: () {}),
          if (courses.isEmpty)
            _EmptyState(
              icon: Icons.menu_book_outlined,
              text: 'لا توجد كورسات في هذا القسم بعد',
            )
          else
            for (final course in courses)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _CourseCard(
                  course: course,
                  onTap: () => context.pushNamed(
                    AppRoute.courseDetails,
                    pathParameters: {'id': course.id},
                  ),
                ),
              ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '٢٠٢٥ — جميع الحقوق محفوظة',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBanner extends StatelessWidget {
  const _CategoryBanner({required this.track});

  final LearningTrack track;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = track.gradientColors(theme.colorScheme);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(track.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أهلاً بك في',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    Text(
                      track.label,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            track.tagline,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(onPressed: onViewAll, child: const Text('عرض الكل')),
        ],
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({required this.teacher, required this.onTap});

  final Teacher teacher;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 180,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 10),
                Text(
                  teacher.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(teacher.subject, style: theme.textTheme.bodySmall),
                const Spacer(),
                Text(
                  '${teacher.coursesCount} كورس',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends ConsumerWidget {
  const _CourseCard({required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unlockedByCoupon = ref.watch(isCourseUnlockedProvider(course.id));
    final isUnlocked = !course.isLocked || unlockedByCoupon;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.menu_book,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(course.teacherName, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isUnlocked ? Icons.lock_open : Icons.lock,
                          size: 16,
                          color: isUnlocked
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${course.lessonsCount} درس',
                          style: theme.textTheme.labelMedium,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 36, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
