import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/models/course.dart';
import '../../../shared/models/sample_data.dart';
import '../../admin/data/catalog_store.dart';
import '../../coupons/data/coupon_repository.dart';
import '../../coupons/presentation/coupon_redemption_sheet.dart';

/// Detail view for a single course: cover, description, lessons list, and
/// CTAs for enrolling or redeeming a coupon.
///
/// Locked / unlocked state is driven entirely by [isCourseUnlockedProvider]
/// — once a coupon redemption flips that provider, this screen rebuilds
/// without needing manual refresh.
class CourseDetailsScreen extends ConsumerWidget {
  const CourseDetailsScreen({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseByIdProvider(courseId));
    final theme = Theme.of(context);

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الكورس')),
        body: const Center(child: Text('الكورس غير موجود')),
      );
    }

    // A course is unlocked if it shipped unlocked OR a coupon unlocked it.
    final unlockedByCoupon = ref.watch(isCourseUnlockedProvider(course.id));
    final isUnlocked = !course.isLocked || unlockedByCoupon;
    final lessons = SampleData.lessonsForCourse(course.id);

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CourseHeader(course: course, isUnlocked: isUnlocked),
          const SizedBox(height: 20),
          if (!isUnlocked)
            _LockedNotice(theme: theme)
          else
            _UnlockedNotice(theme: theme),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: isUnlocked ? () {} : null,
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(isUnlocked ? 'بدء الكورس' : 'الكورس مقفل'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => CouponRedemptionSheet.show(
                    context,
                    prefilledCourseId: course.id,
                  ),
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: const Text('كوبون'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'عن الكورس',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(course.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'الدروس',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${lessons.length})',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final lesson in lessons)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: (isUnlocked || lesson.isFreePreview)
                    ? () => context.pushNamed(
                        AppRoute.lessonPlayer,
                        pathParameters: {
                          'id': course.id,
                          'lessonId': lesson.id,
                        },
                      )
                    : null,
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    isUnlocked || lesson.isFreePreview
                        ? Icons.play_arrow
                        : Icons.lock_outline,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(lesson.title),
                subtitle: Text('${lesson.durationMinutes} دقيقة'),
                trailing: lesson.isFreePreview
                    ? Chip(
                        label: const Text('عرض مجاني'),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        side: BorderSide.none,
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({required this.course, required this.isUnlocked});

  final Course course;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: AlignmentDirectional.bottomStart,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUnlocked ? Icons.lock_open : Icons.lock,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isUnlocked ? 'مفتوح' : 'مقفل',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.subject,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              Text(
                course.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                course.teacherName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LockedNotice extends StatelessWidget {
  const _LockedNotice({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'هذا الكورس مقفل، يرجى الاشتراك أو استخدام كوبون لفتحه',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedNotice extends StatelessWidget {
  const _UnlockedNotice({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_open, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'الكورس مفتوح بالكامل. اضغط بدء الكورس للمشاهدة.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
