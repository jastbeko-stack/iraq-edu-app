# منصة العراق التعليمية — Iraq Edu App

A Flutter mobile application for an Iraqi educational platform targeting **6th Grade Scientific** high school students. Arabic-first, fully RTL.

> **Status:** Project scaffolding. The five product features (phone auth, multi-teacher dashboard, Bunny.net video, coupon redemption, screenshot/recording prevention) are designed for but not yet implemented — see [Roadmap](#roadmap).

---

## Tech stack

| Concern             | Choice                                                                |
|---------------------|-----------------------------------------------------------------------|
| Framework           | Flutter (stable, Dart 3.11+) — Material 3                             |
| Localization / RTL  | `flutter_localizations` + `intl` (Arabic-only, forced `TextDirection.rtl`) |
| State management    | `flutter_riverpod`                                                    |
| Routing             | `go_router` (`StatefulShellRoute.indexedStack` for bottom-nav)        |
| Backend             | Firebase (Auth + Firestore + Cloud Functions) — wired with placeholders |
| Typography          | Cairo (via `google_fonts`)                                            |

---

## Project layout

```
lib/
├── main.dart                       # Entry point: Firebase init, MaterialApp.router, RTL
├── firebase_options.dart           # PLACEHOLDER — replace with `flutterfire configure` output
├── core/
│   ├── router/app_router.dart      # GoRouter graph + AppRoute name constants
│   └── theme/
│       ├── app_colors.dart         # Brand palette
│       └── app_theme.dart          # Material 3 light/dark themes (Cairo font)
├── features/
│   ├── auth/                       # (stub) Phone OTP flow lands here
│   ├── home/presentation/          # Home screen (welcome, featured teachers, courses)
│   ├── teachers/presentation/      # Teacher profile screen
│   ├── courses/presentation/       # Course details screen + coupon sheet
│   └── profile/presentation/       # Profile / settings screen
├── shared/
│   ├── models/                     # Teacher, Course, Lesson, SampleData
│   └── widgets/app_shell.dart      # Bottom-nav shell hosting the four tabs
└── l10n/
    └── app_ar.arb                  # Arabic strings (template ARB)
```

`l10n.yaml` configures Flutter's gen-l10n tool. Strings are co-located in `lib/l10n/`. While the scaffolding uses inline Arabic literals on stub screens (for readability while reviewing the structure), all user-facing strings should migrate to `AppLocalizations` as features are built out.

---

## Getting started

### 1. Install Flutter

This project targets the `stable` channel. Install via [flutter.dev/docs/get-started/install](https://docs.flutter.dev/get-started/install) and confirm:

```bash
flutter --version   # 3.41.x or newer
flutter doctor
```

### 2. Fetch dependencies

```bash
cd iraq_edu_app
flutter pub get
```

### 3. Wire up Firebase

The repo ships with a placeholder `lib/firebase_options.dart` so the app boots without a real Firebase project. To wire up your own:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project-id>
```

This regenerates `lib/firebase_options.dart` and registers Android / iOS apps with your Firebase project. After running it, `Firebase.initializeApp` will run automatically on launch (see `main.dart`).

You'll also need to:

- **Android:** drop `google-services.json` into `android/app/` and apply the Google Services plugin (FlutterFire CLI handles this).
- **iOS:** drop `GoogleService-Info.plist` into `ios/Runner/` (FlutterFire CLI handles this).
- **Auth:** in the Firebase console enable **Phone** sign-in and add your test phone numbers under *Authentication → Sign-in method → Phone*.

### 4. Run the app

```bash
flutter run
```

---

## Architecture notes

### RTL

`MaterialApp.router` is configured with `locale: Locale('ar')` and `supportedLocales: [Locale('ar')]`. A top-level `Directionality(textDirection: TextDirection.rtl)` in the root `builder` forces RTL even if the host platform locale is LTR. All custom layout uses directional primitives (`AlignmentDirectional`, `EdgeInsetsDirectional`, `Icons.chevron_left` for "next", etc.) so flipping LTR later is a single-line change.

### Navigation

`buildRouter()` in `lib/core/router/app_router.dart` defines a `StatefulShellRoute.indexedStack` with four branches (Home / Courses / Teachers / Profile). Each branch keeps its own navigation stack — opening a course detail from Home and switching to another tab and back preserves the detail screen.

Route names are exposed via `AppRoute` constants. Always navigate with named routes, e.g.:

```dart
context.pushNamed(
  AppRoute.courseDetails,
  pathParameters: {'id': course.id},
);
```

### State management

`flutter_riverpod` is wired at the root via `ProviderScope`. As features come online, providers should live next to their feature (`features/auth/data/auth_repository.dart`, etc.) and expose `AsyncValue` consumers for the UI.

### Sample data

`lib/shared/models/sample_data.dart` provides hard-coded teachers/courses so all stub screens render without a backend. Replace these with Firestore-backed repositories as features land — keep the `Teacher` / `Course` / `Lesson` models so the UI doesn't change.

---

## Roadmap

The five product features the app is being built toward, in suggested implementation order:

1. **Phone-number authentication (Firebase)**
   - `verifyPhoneNumber` flow with +964 number entry, OTP entry, and resend
   - `AuthGate` widget at the root that routes pre/post auth users
2. **Multi-teacher dashboard**
   - Firestore `teachers` and `courses` collections
   - Role claim (`teacher`, `student`, `admin`) on the Firebase user
   - Teacher-only screens for managing their own courses
3. **Secure video streaming (Bunny.net)**
   - Cloud Function that issues short-lived signed URLs scoped to user + course
   - `video_player` + `chewie` (or `better_player`) for playback
4. **Coupon system**
   - Firestore `coupons` collection (`code`, `courseId`, `used`, `usedBy`, `expiresAt`)
   - Cloud Function for atomic redemption (transaction marks coupon used + grants entitlement)
5. **Screenshot / recording prevention**
   - Android: `flutter_windowmanager` `FLAG_SECURE` on sensitive routes (player especially)
   - iOS: observe `UIScreen.capturedDidChangeNotification` and blur the player while recording; observe `userDidTakeScreenshotNotification` for telemetry
   - Caveat: iOS has no public API to *block* screenshots — only mitigate

---

## Development

```bash
flutter analyze
flutter test
dart format .
```

Pre-commit setup is intentionally not added at this stage — once CI is configured, hooks should mirror the same `analyze` + `test` commands.

---

## License

Proprietary — all rights reserved.
