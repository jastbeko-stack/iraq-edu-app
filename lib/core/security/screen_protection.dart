import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';

/// Cross-platform "screen protection" gate.
///
/// What we do per platform:
///
/// - **Android** — apply `FLAG_SECURE` to the window. This blocks
///   screenshots and most screen-recording apps system-wide while the
///   app is in the foreground.
///
/// - **iOS** — `FLAG_SECURE` does not exist on iOS. The best we can do
///   is *detect* recording via `UIScreen.captured` and screenshots via
///   `userDidTakeScreenshotNotification`, then blur or replace the
///   sensitive view. The detection lives behind the
///   [iosScreenCaptureChannel] method channel and is intended to be
///   wired to a small Swift listener in `ios/Runner/AppDelegate.swift`
///   when iOS is built.
///
///   We deliberately do **not** claim "screenshot blocking on iOS" —
///   Apple does not expose that API and any package that markets it is
///   either lying or relying on a fragile UIWindow trick.
///
/// - **Web / Desktop** — no-op. `FLAG_SECURE` doesn't apply, and the
///   browser/OS can always screenshot.
abstract final class ScreenProtection {
  /// Method channel that the iOS native side posts events on:
  /// - `screenRecordingChanged` (bool isCapturing)
  /// - `screenshotTaken`
  ///
  /// The Flutter side listens via [listenIos] and reacts (e.g. blurs
  /// the lesson player while `isCapturing == true`).
  static const iosScreenCaptureChannel = MethodChannel(
    'app.iraqedu/screen_capture',
  );

  /// Apply the strongest available protection for the current platform.
  /// Safe to call multiple times.
  static Future<void> enableForApp() async {
    if (kIsWeb) return;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        try {
          await FlutterWindowManagerPlus.addFlags(
            FlutterWindowManagerPlus.FLAG_SECURE,
          );
        } on PlatformException catch (e) {
          debugPrint('FLAG_SECURE failed: $e');
        }
        break;
      case TargetPlatform.iOS:
        // Nothing to do here at startup. The iOS detection listener is
        // started lazily by [listenIos] when the lesson player mounts.
        break;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        break;
    }
  }

  /// Subscribe to iOS screen capture / screenshot events. The supplied
  /// [onCaptureChanged] is called with `true` while the screen is being
  /// recorded and `false` when recording stops; [onScreenshot] fires
  /// once per screenshot.
  ///
  /// Returns a function that tears down the listener.
  ///
  /// The accompanying Swift code in `AppDelegate.swift` watches:
  /// - `UIScreen.capturedDidChangeNotification` for recording, and
  /// - `UIApplication.userDidTakeScreenshotNotification` for snapshots.
  static VoidCallback listenIos({
    required ValueChanged<bool> onCaptureChanged,
    VoidCallback? onScreenshot,
  }) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return () {};
    }

    Future<dynamic> handler(MethodCall call) async {
      switch (call.method) {
        case 'screenRecordingChanged':
          final isCapturing = (call.arguments as bool?) ?? false;
          onCaptureChanged(isCapturing);
          break;
        case 'screenshotTaken':
          onScreenshot?.call();
          break;
      }
    }

    iosScreenCaptureChannel.setMethodCallHandler(handler);
    return () => iosScreenCaptureChannel.setMethodCallHandler(null);
  }
}
