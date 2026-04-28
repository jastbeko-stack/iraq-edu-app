# منصة العراق التعليمية — Iraq Edu App

A Flutter mobile application for an Iraqi educational platform targeting **6th Grade Scientific** high school students. Arabic-first, fully RTL.

> **Status:** UI + flow complete. Real backend (Firebase / Bunny.net) is wired through abstractions that can be flipped from local stubs to production by configuring credentials and deploying the Cloud Functions in `/functions`.

---

## Tech stack

| Concern             | Choice                                                                     |
|---------------------|----------------------------------------------------------------------------|
| Framework           | Flutter (stable, Dart 3.11+) — Material 3                                  |
| Localization / RTL  | `flutter_localizations` + `intl` (Arabic-only, forced `TextDirection.rtl`) |
| State management    | `flutter_riverpod`                                                         |
| Routing             | `go_router` (`StatefulShellRoute.indexedStack` for bottom-nav)             |
| Persistence         | `shared_preferences` (local) → swap to Firestore via Cloud Functions       |
| Video player        | `chewie` + `video_player` with token-authed Bunny.net Stream HLS           |
| Auth                | Local stub today — Firebase Phone OTP via `firebase_auth` once configured  |
| Screen protection   | `flutter_windowmanager_plus` (Android FLAG_SECURE) + iOS detection channel |
| Backend logic       | Firebase Cloud Functions (`/functions`, TypeScript)                        |
| Typography          | Cairo (via `google_fonts`)                                                 |

---

## Project layout

```
lib/
├── main.dart                       # Entry: Firebase init, screen protection, MaterialApp.router, RTL
├── firebase_options.dart           # PLACEHOLDER — replace with `flutterfire configure` output
├── core/
│   ├── router/app_router.dart      # GoRouter graph + AppRoute name constants
│   ├── security/screen_protection  # FLAG_SECURE (Android) + iOS capture detection channel
│   └── theme/                      # Material 3 light/dark themes (Cairo font)
├── features/
│   ├── auth/                       # Phone OTP UI flow + AuthController stub
│   ├── coupons/                    # Course coupons (no prefix) — sheet, repo, providers
│   ├── courses/                    # Course details + lesson list
│   ├── home/                       # Home (welcome, featured teachers, courses)
│   ├── lessons/                    # Player screen + Bunny stream service abstraction
│   ├── profile/                    # حسابي — auth state + entitlements + settings
│   ├── study_guides/               # الملازم — separate store with G- prefixed coupons
│   └── teachers/                   # Teacher profile screen
├── shared/
│   ├── models/                     # Teacher, Course, Lesson, SampleData
│   └── widgets/app_shell.dart      # 4-tab bottom-nav (Home / Guides / Teachers / Profile)
└── l10n/app_ar.arb                 # Arabic strings (template ARB)

functions/                          # Cloud Functions: redeemCoupon + getSignedLessonUrl
firestore.rules                     # Locks coupons & entitlements to Cloud Functions only
firebase.json                       # Functions + Firestore deploy config
```

---

## Getting started

### 1. Install Flutter

This project targets the `stable` channel.

```bash
flutter --version   # 3.41.x or newer
flutter doctor
```

### 2. Fetch dependencies

```bash
cd iraq_edu_app
flutter pub get
```

### 3. Run the app

```bash
flutter run                # mobile (Android/iOS)
flutter run -d chrome      # web preview
```

The app boots fully without any external setup — the local stubs cover phone auth, coupon redemption, and video playback (a public sample MP4).

---

## Going to production

The four steps below convert local stubs to a real backend. They are independent — wire whichever you need first.

### 4. Wire up Firebase (Auth + Firestore)

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project-id>
```

This regenerates `lib/firebase_options.dart` and registers Android / iOS apps with your Firebase project. After running it, `Firebase.initializeApp` will run automatically on launch (see `main.dart`).

You'll also need to:

- **Android:** drop `google-services.json` into `android/app/` (handled by FlutterFire CLI).
- **iOS:** drop `GoogleService-Info.plist` into `ios/Runner/` (handled by FlutterFire CLI).
- **Auth:** in the Firebase console enable **Phone** sign-in and add test numbers under *Authentication → Sign-in method → Phone*.
- Replace `AuthController` (`lib/features/auth/data/auth_controller.dart`) with the `firebase_auth` `verifyPhoneNumber` flow — the state machine (`AuthSignedOut`, `AuthCodeSent`, `AuthSignedIn`, `AuthError`) already mirrors Firebase's API exactly, so the swap is one file.

### 5. Deploy Cloud Functions (coupon redemption + Bunny signing)

```bash
cd functions
npm install

firebase functions:secrets:set BUNNY_STREAM_LIBRARY_ID
firebase functions:secrets:set BUNNY_STREAM_CDN_HOSTNAME
firebase functions:secrets:set BUNNY_STREAM_TOKEN_SIGNING_KEY

npm run build
firebase deploy --only functions
firebase deploy --only firestore:rules
```

Two callables ship in `functions/src/index.ts`:

- **`redeemCoupon`** — atomic Firestore transaction. Validates the code, marks it used, and grants entitlements. Prevents double-spend even under concurrent requests.
- **`getSignedLessonUrl`** — verifies the caller has access to the parent course, then mints a short-lived token-authenticated Bunny Stream HLS URL using the SHA-256 algorithm Bunny documents.

After deploy, swap `CouponRepository` and `BunnyStreamService` to call these callables. The Riverpod providers (`couponRepositoryProvider`, `bunnyStreamServiceProvider`) are the only edit points.

### 6. Bunny.net Stream

The signing key **must never ship in the app** — the deploy step above sets it as a secret only the function reads. Token signing algorithm (in `functions/src/index.ts`):

```
tokenPath = "/<videoGuid>/playlist.m3u8"
expires   = now + 1 hour
token     = base64url( sha256_bytes(signingKey + tokenPath + expires) )
url       = https://<cdnHost><tokenPath>?token=<token>&expires=<expires>
```

Reference: [Bunny Stream — Token Authentication](https://docs.bunny.net/docs/stream-embedding-videos-token-authentication).

### 7. Screen protection

- **Android** — `flutter_windowmanager_plus` applies `FLAG_SECURE` to the window in `main()`. This blocks system-level screenshots and most third-party screen recorders. No additional setup required.
- **iOS** — `ios/Runner/AppDelegate.swift` ships a Swift listener that posts `screenRecordingChanged` and `screenshotTaken` events on the `app.iraqedu/screen_capture` method channel. The lesson player subscribes via `ScreenProtection.listenIos` and overlays a "stopped during recording" blocker. Apple does **not** expose an API to *block* screenshots — anything that claims it does is fragile or dishonest.

---

## Demo data

While the local stubs are in place:

- **Phone OTP** — any Iraqi mobile in `+9647XXXXXXXX` format. Verification code: **`123456`**.
- **Course coupons** — `MATH2025`, `PHYSICS2025`, `BIO2025`, `CALC2025`, `MECH2025`, `CELL2025`, `ALL2025` (master).
- **Study guide coupons** — `G-MATH-2025`, `G-PHYS-2025`, `G-BIO-2025`, `G-MINISTERIAL-2025`, `G-ALL-2025` (master).

The حسابي tab has a "إعادة تعيين" tile that wipes both unlock sets so you can re-test.

---

## Architecture notes

### RTL

`MaterialApp.router` is configured with `locale: Locale('ar')` and `supportedLocales: [Locale('ar')]`. A top-level `Directionality(textDirection: TextDirection.rtl)` in the root `builder` forces RTL even if the host platform locale is LTR. All custom layout uses directional primitives (`AlignmentDirectional`, `EdgeInsetsDirectional`).

### Navigation

`buildRouter()` defines a `StatefulShellRoute.indexedStack` with four branches (الرئيسية / الملازم / المدرسون / حسابي). Each branch keeps its own navigation stack.

### Two coupon namespaces

Course coupons and study-guide coupons are intentionally kept in **separate stores** so a code from one cannot accidentally unlock the other:

- Course codes are unprefixed (`MATH2025`).
- Study-guide codes are `G-` prefixed (`G-MATH-2025`).
- Two SharedPreferences keys, two repositories, two Riverpod providers.
- Two Firestore coupon `type`s (`"course"` vs `"guide"`) once Cloud Functions are live.

### Sample data

`lib/shared/models/sample_data.dart` and `lib/features/study_guides/data/study_guides_sample_data.dart` provide hard-coded data so all screens render without a backend. Replace with Firestore-backed repositories as features land — keep the model classes stable so the UI doesn't change.

---

## Development

```bash
flutter analyze
flutter test
dart format .
```

---

## License

Proprietary — all rights reserved.
