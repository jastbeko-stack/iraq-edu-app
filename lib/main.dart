import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/security/screen_protection.dart';
import 'core/theme/app_theme.dart';
import 'features/coupons/data/coupon_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  // Block screenshots/recording on Android (FLAG_SECURE) before the first
  // frame paints. No-op on web/desktop and on iOS (where Apple does not
  // expose a "block screenshots" API — see [ScreenProtection]).
  await ScreenProtection.enableForApp();
  // Make the status bar transparent so it blends with the AppBar / page
  // background. Each screen's AppBar can still override icon brightness via
  // [AppBarTheme.systemOverlayStyle] if needed.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark, // iOS
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  // Draw behind the system bars (Android edge-to-edge).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Resolve SharedPreferences once at boot so synchronous providers can rely
  // on it being available immediately.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const IraqEduApp(),
    ),
  );
}

/// Initializes Firebase if real options have been generated via
/// `flutterfire configure`. While the placeholder options are in place, this
/// is a no-op so the app boots without crashing during scaffolding.
Future<void> _initializeFirebase() async {
  final options = DefaultFirebaseOptions.currentPlatform;
  if (options == null) {
    if (kDebugMode) {
      debugPrint(
        '[firebase] Skipping Firebase.initializeApp — placeholder options. '
        'Run `flutterfire configure` to wire up your project.',
      );
    }
    return;
  }
  await Firebase.initializeApp(options: options);
}

/// Root widget. Configures Arabic-only localization, the Material 3 theme,
/// and the [GoRouter] navigation graph.
class IraqEduApp extends ConsumerStatefulWidget {
  const IraqEduApp({super.key});

  @override
  ConsumerState<IraqEduApp> createState() => _IraqEduAppState();
}

class _IraqEduAppState extends ConsumerState<IraqEduApp> {
  late final _router = ref.read(routerProvider);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'منصة المهندس التعليمية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      // Arabic-only for now. Add additional locales here when ready.
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder: (context, child) {
        // Force RTL regardless of device locale so layout is consistent.
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
