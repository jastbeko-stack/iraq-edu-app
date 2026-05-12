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
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                // Strong iOS-style frosted-glass blur.
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 0.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: NavigationBarTheme(
                    data: NavigationBarThemeData(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      // Dark translucent pill behind the active destination,
                      // matching the reference screenshot.
                      indicatorColor:
                          AppColors.primary.withValues(alpha: 0.18),
                      indicatorShape: const StadiumBorder(),
                      labelTextStyle:
                          WidgetStateProperty.resolveWith((states) {
                        final selected =
                            states.contains(WidgetState.selected);
                        return TextStyle(
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                          color: selected
                              ? AppColors.primary
                              : Colors.black87,
                        );
                      }),
                      iconTheme: WidgetStateProperty.resolveWith((states) {
                        final selected =
                            states.contains(WidgetState.selected);
                        return IconThemeData(
                          color: selected
                              ? AppColors.primary
                              : Colors.black87,
                          size: 24,
                        );
                      }),
                    ),
                    child: NavigationBar(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      height: 68,
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: (index) =>
                          navigationShell.goBranch(
                        index,
                        initialLocation:
                            index == navigationShell.currentIndex,
                      ),
                      // RTL order (right → left): الرئيسية, المواد,
                      // الأسئلة, التقويم, حسابي.
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
        ),
      ),
    );
  }
}
