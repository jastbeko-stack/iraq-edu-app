import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/data/admin_auth.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_login_screen.dart';
import '../../features/auth/data/auth_controller.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/coming_soon/presentation/coming_soon_screen.dart';
import '../../features/courses/presentation/course_details_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/lessons/presentation/lesson_player_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/study_guides/presentation/study_guide_details_screen.dart';
import '../../features/study_guides/presentation/study_guides_store_screen.dart';
import '../../features/teachers/presentation/teacher_profile_screen.dart';
import '../../features/teachers/presentation/teachers_list_screen.dart';
import '../../shared/widgets/app_shell.dart';

/// Route name constants used throughout the app.
abstract final class AppRoute {
  static const home = 'home';
  static const studyGuides = 'study-guides';
  static const studyGuideDetails = 'study-guide-details';
  static const teachers = 'teachers';
  static const profile = 'profile';
  static const teacherProfile = 'teacher-profile';
  static const teacherProfileFromTab = 'teacher-profile-from-tab';
  static const courseDetails = 'course-details';
  static const lessonPlayer = 'lesson-player';
  static const questions = 'questions';
  static const calendar = 'calendar';
  static const welcome = 'welcome';
  static const adminLogin = 'admin-login';
  static const adminDashboard = 'admin-dashboard';
}

/// Builds the [GoRouter] used by [MaterialApp.router].
///
/// The bottom navigation lives inside [AppShell] via a `StatefulShellRoute`,
/// which gives each tab its own navigation stack. Detail screens (teacher
/// profile, course details) are pushed on top of the active tab stack so the
/// shell remains visible only on top-level routes.
final routerProvider = Provider<GoRouter>(buildRouter);

/// Bridges Riverpod state changes to a [Listenable] that GoRouter can use
/// via its `refreshListenable` to re-run redirects when the user signs in
/// or out.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<bool>(isSignedInProvider, (_, _) => notifyListeners());
  }
}

GoRouter buildRouter(Ref ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isAdminLoggedIn = ref.read(adminAuthProvider);
      final isSignedIn = ref.read(isSignedInProvider);

      // Admin portal has its own auth gate.
      final goingToAdmin = loc.startsWith('/admin') && loc != '/admin/login';
      if (goingToAdmin && !isAdminLoggedIn) return '/admin/login';
      if (loc == '/admin/login' && isAdminLoggedIn) return '/admin';

      // Student-facing app: the welcome / sign-in screen is the gate.
      // Anything inside the shell requires a Supabase session. Once signed
      // in, /welcome itself bounces back to the Hub.
      final goingToWelcome = loc == '/welcome';
      final goingToAdminArea = loc.startsWith('/admin');
      if (!isSignedIn && !goingToWelcome && !goingToAdminArea) {
        return '/welcome';
      }
      if (isSignedIn && goingToWelcome) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        name: AppRoute.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/admin/login',
        name: AppRoute.adminLogin,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: AppRoute.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: AppRoute.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'teachers',
                    name: AppRoute.teachers,
                    builder: (context, state) => const TeachersListScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: AppRoute.teacherProfileFromTab,
                        builder: (context, state) => TeacherProfileScreen(
                          teacherId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'teacher/:id',
                    name: AppRoute.teacherProfile,
                    builder: (context, state) => TeacherProfileScreen(
                      teacherId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'course/:id',
                    name: AppRoute.courseDetails,
                    builder: (context, state) => CourseDetailsScreen(
                      courseId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'lesson/:lessonId',
                        name: AppRoute.lessonPlayer,
                        builder: (context, state) => LessonPlayerScreen(
                          courseId: state.pathParameters['id']!,
                          lessonId: state.pathParameters['lessonId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/guides',
                name: AppRoute.studyGuides,
                builder: (context, state) => const StudyGuidesStoreScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: AppRoute.studyGuideDetails,
                    builder: (context, state) => StudyGuideDetailsScreen(
                      guideId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/questions',
                name: AppRoute.questions,
                builder: (context, state) => const ComingSoonScreen(
                  title: 'الأسئلة',
                  icon: Icons.help_outline_rounded,
                  description:
                      'بنك أسئلة الامتحانات الوزارية مع الأجوبة — قريباً.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                name: AppRoute.calendar,
                builder: (context, state) => const ComingSoonScreen(
                  title: 'التقويم',
                  icon: Icons.calendar_month_rounded,
                  description:
                      'مواعيد الحصص والامتحانات والملازم الجديدة — قريباً.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoute.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
