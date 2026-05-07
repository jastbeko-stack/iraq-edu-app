import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../admin/data/catalog_store.dart';
import '../../coupons/data/coupon_repository.dart';

/// Detailed view for a single teacher: bio, stats, and the list of courses
/// they teach. Course tiles deep-link to [CourseDetailsScreen] and reflect
/// the live unlock state from [isCourseUnlockedProvider].
class TeacherProfileScreen extends ConsumerWidget {
  const TeacherProfileScreen({required this.teacherId, super.key});

  final String teacherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(teacherByIdProvider(teacherId));
    final theme = Theme.of(context);

    if (teacher == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('صفحة المدرس')),
        body: const Center(child: Text('المدرس غير موجود')),
      );
    }

    final courses = ref.watch(coursesByTeacherProvider(teacher.id));
    final unlocked = ref.watch(unlockedCoursesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(teacher.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  teacher.name.characters.first,
                  style: theme.textTheme.headlineSmall?.copyWith(
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher.subject,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'كورس',
                  value: teacher.coursesCount.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'طالب',
                  value: teacher.studentsCount.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'نبذة عن المدرس',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(teacher.bio, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text(
            'كورسات المدرس',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (courses.isEmpty)
            Text('قريباً', style: theme.textTheme.bodyMedium)
          else
            for (final c in courses)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(c.title),
                  subtitle: Text('${c.lessonsCount} درس'),
                  trailing: Icon(
                    !c.isLocked || unlocked.contains(c.id)
                        ? Icons.lock_open
                        : Icons.lock,
                    color: !c.isLocked || unlocked.contains(c.id)
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  onTap: () => context.pushNamed(
                    AppRoute.courseDetails,
                    pathParameters: {'id': c.id},
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
