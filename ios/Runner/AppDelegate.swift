import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  /// Method channel matched in
  /// `lib/core/security/screen_protection.dart`. We post:
  /// - `screenRecordingChanged` (Bool) on UIScreen.capturedDidChange
  /// - `screenshotTaken` on userDidTakeScreenshot
  ///
  /// iOS does *not* expose an API to *block* screenshots; we can only
  /// detect them and react (e.g. blur the player view).
  private var screenCaptureChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    setupScreenCaptureObservers()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let controller = window?.rootViewController as? FlutterViewController {
      screenCaptureChannel = FlutterMethodChannel(
        name: "app.iraqedu/screen_capture",
        binaryMessenger: controller.binaryMessenger
      )
      // Push the current capture state as soon as the channel is ready
      // so a player view that mounts after launch starts in the right
      // mode.
      screenCaptureChannel?.invokeMethod(
        "screenRecordingChanged",
        arguments: UIScreen.main.isCaptured
      )
    }
  }

  private func setupScreenCaptureObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleCapturedDidChange),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
  }

  @objc private func handleCapturedDidChange() {
    screenCaptureChannel?.invokeMethod(
      "screenRecordingChanged",
      arguments: UIScreen.main.isCaptured
    )
  }

  @objc private func handleScreenshot() {
    screenCaptureChannel?.invokeMethod("screenshotTaken", arguments: nil)
  }
}
