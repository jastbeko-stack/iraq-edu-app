import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/course.dart';
import '../../../shared/models/teacher.dart';
import '../../admin/data/catalog_store.dart';
import '../../study_guides/domain/study_guide.dart';
import '../../tracks/data/track_providers.dart';

/// Full-screen search experience opened from the Hub search bar.
///
/// As the user types, results from three live data sources are filtered in
/// memory and rendered in grouped sections: teachers, courses, and study
/// guides. Tapping a result navigates to the relevant detail screen.
class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teachers = ref.watch(teachersProvider);
    final courses = ref.watch(coursesProvider);
    final guides = ref.watch(allStudyGuidesProvider);

    final q = _query.trim().toLowerCase();
    final filteredTeachers = q.isEmpty
        ? const <Teacher>[]
        : teachers
              .where(
                (t) =>
                    t.name.toLowerCase().contains(q) ||
                    t.subject.toLowerCase().contains(q) ||
                    t.bio.toLowerCase().contains(q),
              )
              .toList();
    final filteredCourses = q.isEmpty
        ? const <Course>[]
        : courses
              .where(
                (c) =>
                    c.title.toLowerCase().contains(q) ||
                    c.teacherName.toLowerCase().contains(q) ||
                    c.subject.toLowerCase().contains(q) ||
                    c.description.toLowerCase().contains(q),
              )
              .toList();
    final filteredGuides = q.isEmpty
        ? const <StudyGuide>[]
        : guides
              .where(
                (g) =>
                    g.title.toLowerCase().contains(q) ||
                    g.author.toLowerCase().contains(q) ||
                    g.subject.toLowerCase().contains(q) ||
                    g.description.toLowerCase().contains(q),
              )
              .toList();

    final totalResults =
        filteredTeachers.length + filteredCourses.length + filteredGuides.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // Blue search header matching the Hub style.
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    tooltip: 'رجوع',
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsetsDirectional.only(
                        start: 14,
                        end: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF334155),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: true,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              cursorColor: AppColors.primary,
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: 'ابحث عن كورس، ملزمة، أو مدرّس…',
                                hintStyle: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              textInputAction: TextInputAction.search,
                              onChanged: (v) => setState(() => _query = v),
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFF64748B),
                              ),
                              onPressed: () {
                                setState(() {
                                  _controller.clear();
                                  _query = '';
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Counter strip.
            if (q.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Row(
                  children: [
                    Text(
                      totalResults == 0
                          ? 'لا توجد نتائج'
                          : '$totalResults نتيجة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            // Results list.
            Expanded(
              child: q.isEmpty
                  ? _EmptyState()
                  : (totalResults == 0
                        ? _NoResultsState(query: _query)
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                            children: [
                              if (filteredTeachers.isNotEmpty) ...[
                                _SectionHeader(
                                  title: 'المدرّسون',
                                  count: filteredTeachers.length,
                                ),
                                for (final t in filteredTeachers)
                                  _TeacherTile(teacher: t),
                              ],
                              if (filteredCourses.isNotEmpty) ...[
                                _SectionHeader(
                                  title: 'الكورسات',
                                  count: filteredCourses.length,
                                ),
                                for (final c in filteredCourses)
                                  _CourseTile(course: c),
                              ],
                              if (filteredGuides.isNotEmpty) ...[
                                _SectionHeader(
                                  title: 'الملازم',
                                  count: filteredGuides.length,
                                ),
                                for (final g in filteredGuides)
                                  _GuideTile(guide: g),
                              ],
                            ],
                          )),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'ابدأ بالكتابة للبحث',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'مدرّسون · كورسات · ملازم',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.query});
  final String query;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_rounded,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'ما حصلنا شي عن "$query"',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'جرّب كلمات أخرى أو اسم المدرّس',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 14, 6, 8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherTile extends StatelessWidget {
  const _TeacherTile({required this.teacher});
  final Teacher teacher;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        title: Text(
          teacher.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(teacher.subject),
        trailing: const Icon(Icons.chevron_left, color: Color(0xFF94A3B8)),
        onTap: () => context.goNamed(
          AppRoute.teacherProfile,
          pathParameters: {'id': teacher.id},
        ),
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course});
  final Course course;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.menu_book_outlined,
            color: AppColors.secondary,
          ),
        ),
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${course.teacherName} · ${course.lessonsCount} درس'),
        trailing: course.isLocked
            ? const Icon(Icons.lock_outline, color: AppColors.accent)
            : const Icon(Icons.chevron_left, color: Color(0xFF94A3B8)),
        onTap: () => context.goNamed(
          AppRoute.courseDetails,
          pathParameters: {'id': course.id},
        ),
      ),
    );
  }
}

class _GuideTile extends StatelessWidget {
  const _GuideTile({required this.guide});
  final StudyGuide guide;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.collections_bookmark_outlined,
            color: AppColors.accent,
          ),
        ),
        title: Text(
          guide.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${guide.author} · ${guide.subject}'),
        trailing: guide.isLocked
            ? const Icon(Icons.lock_outline, color: AppColors.accent)
            : const Icon(Icons.chevron_left, color: Color(0xFF94A3B8)),
        onTap: () => context.goNamed(
          AppRoute.studyGuideDetails,
          pathParameters: {'id': guide.id},
        ),
      ),
    );
  }
}
