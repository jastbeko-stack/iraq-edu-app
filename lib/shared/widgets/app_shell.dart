import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

/// Bottom-navigation shell that hosts the five top-level tabs.
///
/// Each tab is its own `StatefulShellBranch`, so its navigation stack is
/// preserved across tab switches.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    // Force the status / system-nav overlays to be transparent for the entire
    // app shell, regardless of which screen is active. Individual screens may
    // still override via their own AnnotatedRegion if needed.
    final overlay = brightness == Brightness.light
        ? const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          )
        : const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        // extendBodyBehindAppBar lets the body paint under the status bar so
        // there's no opaque white gap at the very top.
        extendBodyBehindAppBar: true,
        // Let the body paint under the bottom navigation so the frosted /
        // "watery" glass effect can pick up the content scrolling beneath it.
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            // Frosted-glass blur: lifts the content below the bar slightly
            // so the bar reads as a translucent "watery" surface.
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                // Light teal/blue tint with low alpha so the underlying page
                // bleeds through, giving the bar a watery look.
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.55),
                    AppColors.primary.withValues(alpha: 0.18),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 0.6,
                  ),
                ),
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor:
                      AppColors.primary.withValues(alpha: 0.18),
                ),
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) => navigationShell.goBranch(
                    index,
                    // Re-tap on the active tab pops to the root of that
                    // tab's stack.
                    initialLocation:
                        index == navigationShell.currentIndex,
                  ),
                  // RTL order (right → left): الرئيسية, المواد, الأسئلة,
                  // التقويم, حسابي. The first destination renders on the
                  // right edge in an RTL Directionality.
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'الرئيسية',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: 'المواد',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.quiz_outlined),
                      selectedIcon: Icon(Icons.quiz),
                      label: 'الأسئلة',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: 'التقويم',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'حسابي',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
