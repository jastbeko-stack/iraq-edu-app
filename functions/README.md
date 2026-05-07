# Cloud Functions — Iraq Edu App

Server-side logic that **must not run in the client**:

- `redeemCoupon` — atomic Firestore transaction marking a coupon as used
  and granting the caller's entitlements. Prevents double-spend even
  under concurrent redemption.
- `getSignedLessonUrl` — verifies the caller has access to the parent
  course, then mints a short-lived token-authenticated Bunny.net Stream
  HLS URL. The signing key never leaves the function.

## Deploy

```bash
# 1. Install deps
cd functions
npm install

# 2. Set Bunny secrets (one-time, project-scoped)
firebase functions:secrets:set BUNNY_STREAM_LIBRARY_ID
firebase functions:secrets:set BUNNY_STREAM_CDN_HOSTNAME
firebase functions:secrets:set BUNNY_STREAM_TOKEN_SIGNING_KEY

# 3. Build & deploy
npm run build
firebase deploy --only functions
```

## Firestore data model

```
coupons/{code}
  type: "course" | "guide"
  targetIds: string[]
  used: bool
  usedBy?: uid
  usedAt?: timestamp

entitlements/{uid}
  courseIds: string[]
  guideIds: string[]
  updatedAt: timestamp

courses/{courseId}/lessons/{lessonId}
  ...
  isFreePreview: bool
  bunnyVideoId: string
```

## Wiring the Flutter client

After deploy, replace the local stubs:

- `CouponRepository` → call `redeemCoupon` callable, then refresh
  `entitlements/{uid}` from Firestore.
- `BunnyStreamService` → call `getSignedLessonUrl` callable. The current
  abstract interface in
  `lib/features/lessons/data/bunny_stream_service.dart` is the contract
  the callable returns (a `Uri` you can hand to `video_player`).

Both swaps are one-file changes — the rest of the app is already
binding via Riverpod providers.
