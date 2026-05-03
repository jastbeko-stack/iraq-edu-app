import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../data/admin_auth.dart';
import 'tabs/admin_coupons_tab.dart';
import 'tabs/admin_courses_tab.dart';
import 'tabs/admin_guides_tab.dart';
import 'tabs/admin_teachers_tab.dart';

/// Admin shell. Hosts 4 tabs:
/// - المدرسون: CRUD on teachers (filtered by track)
/// - الكورسات: CRUD on courses linked to teachers
/// - الملازم: CRUD on study guides + mock PDF metadata "upload"
/// - الكوبونات: generate / revoke course + guide coupons
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
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
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.person_outline), text: 'المدرسون'),
              Tab(icon: Icon(Icons.menu_book_outlined), text: 'الكورسات'),
              Tab(
                icon: Icon(Icons.collections_bookmark_outlined),
                text: 'الملازم',
              ),
              Tab(
                icon: Icon(Icons.confirmation_number_outlined),
                text: 'الكوبونات',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
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
