import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../data/admin_auth.dart';
import '../data/students_service.dart';
import 'tabs/admin_coupons_tab.dart';
import 'tabs/admin_courses_tab.dart';
import 'tabs/admin_guides_tab.dart';
import 'tabs/admin_students_tab.dart';
import 'tabs/admin_teachers_tab.dart';

/// Admin shell. Hosts 5 tabs:
/// - الطلاب: read-only roster of registered student accounts (from Supabase)
/// - المدرسون: CRUD on teachers (filtered by track)
/// - الكورسات: CRUD on courses linked to teachers
/// - الملازم: CRUD on study guides + Supabase PDF upload
/// - الكوبونات: generate / revoke course + guide coupons
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newCount = ref.watch(newStudentsCountProvider);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة الإدارة'),
          actions: [
            IconButton(
              tooltip: 'تسجيل الخروج',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(adminAuthProvider.notifier).signOut();
                if (!context.mounted) return;
                context.goNamed(AppRoute.adminLogin);
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                icon: _StudentsTabIcon(newCount: newCount),
                text: 'الطلاب',
              ),
              const Tab(icon: Icon(Icons.person_outline), text: 'المدرسون'),
              const Tab(icon: Icon(Icons.menu_book_outlined), text: 'الكورسات'),
              const Tab(
                icon: Icon(Icons.collections_bookmark_outlined),
                text: 'الملازم',
              ),
              const Tab(
                icon: Icon(Icons.confirmation_number_outlined),
                text: 'الكوبونات',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminStudentsTab(),
            AdminTeachersTab(),
            AdminCoursesTab(),
            AdminGuidesTab(),
            AdminCouponsTab(),
          ],
        ),
      ),
    );
  }
}

class _StudentsTabIcon extends StatelessWidget {
  const _StudentsTabIcon({required this.newCount});
  final int newCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (newCount <= 0) return const Icon(Icons.groups_outlined);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.groups_outlined),
        PositionedDirectional(
          top: -4,
          end: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.surface, width: 1.5),
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            alignment: Alignment.center,
            child: Text(
              newCount > 99 ? '99+' : '$newCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
