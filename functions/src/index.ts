/**
 * Cloud Functions for the Iraq Edu App.
 *
 * Two callable functions:
 * 1. `redeemCoupon`        — atomic Firestore transaction. Validates the
 *                            coupon, marks it as used, and grants the
 *                            calling user the entitlements (course ids
 *                            and/or study-guide ids).
 * 2. `getSignedLessonUrl`  — Bunny.net Stream URL signing. Verifies the
 *                            caller has access to the parent course, then
 *                            mints a short-lived token-authenticated HLS
 *                            URL.
 *
 * Both functions require the caller to be authenticated via Firebase Auth
 * (phone OTP) — `request.auth.uid` must be present.
 *
 * Firestore layout (created on first redemption):
 *   coupons/{code}                    { type: 'course'|'guide',
 *                                       targetIds: string[], used: bool,
 *                                       usedBy?: uid, usedAt?: timestamp }
 *   entitlements/{uid}                { courseIds: string[],
 *                                       guideIds: string[],
 *                                       updatedAt: timestamp }
 *
 * Deploy:
 *   $ npm --prefix functions run build
 *   $ firebase deploy --only functions
 *
 * Required runtime config (set once per project):
 *   $ firebase functions:secrets:set BUNNY_STREAM_LIBRARY_ID
 *   $ firebase functions:secrets:set BUNNY_STREAM_CDN_HOSTNAME
 *   $ firebase functions:secrets:set BUNNY_STREAM_TOKEN_SIGNING_KEY
 */

import {createHash} from "crypto";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {
  HttpsError,
  onCall,
  CallableRequest,
} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";

initializeApp();
const db = getFirestore();

// Secrets — bound at function deploy time, never logged.
const BUNNY_LIBRARY_ID = defineSecret("BUNNY_STREAM_LIBRARY_ID");
const BUNNY_CDN_HOSTNAME = defineSecret("BUNNY_STREAM_CDN_HOSTNAME");
const BUNNY_SIGNING_KEY = defineSecret("BUNNY_STREAM_TOKEN_SIGNING_KEY");

// ---------------------------------------------------------------------------
// redeemCoupon
// ---------------------------------------------------------------------------

interface RedeemCouponRequest {
  code: string;
}

interface RedeemCouponResponse {
  type: "course" | "guide";
  targetIds: string[];
  newlyUnlocked: string[];
}

export const redeemCoupon = onCall<RedeemCouponRequest, Promise<RedeemCouponResponse>>(
  async (request: CallableRequest<RedeemCouponRequest>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }

    const code = (request.data?.code ?? "").trim().toUpperCase();
    if (!code) {
      throw new HttpsError("invalid-argument", "Coupon code is required.");
    }

    const couponRef = db.collection("coupons").doc(code);
    const entitlementRef = db.collection("entitlements").doc(uid);

    return db.runTransaction(async (tx) => {
      const couponSnap = await tx.get(couponRef);
      if (!couponSnap.exists) {
        throw new HttpsError("not-found", "Invalid coupon code.");
      }

      const coupon = couponSnap.data() as {
        type: "course" | "guide";
        targetIds: string[];
        used?: boolean;
      };

      if (coupon.used) {
        throw new HttpsError(
          "already-exists",
          "This coupon has already been used."
        );
      }

      const entSnap = await tx.get(entitlementRef);
      const existingCourseIds: string[] = entSnap.exists
        ? (entSnap.data()?.courseIds as string[]) ?? []
        : [];
      const existingGuideIds: string[] = entSnap.exists
        ? (entSnap.data()?.guideIds as string[]) ?? []
        : [];

      const existing = coupon.type === "course"
        ? existingCourseIds
        : existingGuideIds;
      const newlyUnlocked = coupon.targetIds.filter(
        (id) => !existing.includes(id)
      );

      const mergedCourseIds = coupon.type === "course"
        ? Array.from(new Set([...existingCourseIds, ...coupon.targetIds]))
        : existingCourseIds;
      const mergedGuideIds = coupon.type === "guide"
        ? Array.from(new Set([...existingGuideIds, ...coupon.targetIds]))
        : existingGuideIds;

      tx.set(couponRef, {
        used: true,
        usedBy: uid,
        usedAt: FieldValue.serverTimestamp(),
      }, {merge: true});

      tx.set(entitlementRef, {
        courseIds: mergedCourseIds,
        guideIds: mergedGuideIds,
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});

      return {
        type: coupon.type,
        targetIds: coupon.targetIds,
        newlyUnlocked,
      };
    });
  }
);

// ---------------------------------------------------------------------------
// getSignedLessonUrl
// ---------------------------------------------------------------------------

interface GetSignedUrlRequest {
  courseId: string;
  lessonId: string;
  bunnyVideoId: string;
}

interface GetSignedUrlResponse {
  url: string;
  expiresAt: number;
}

export const getSignedLessonUrl = onCall<
  GetSignedUrlRequest,
  Promise<GetSignedUrlResponse>
>(
  {
    secrets: [BUNNY_LIBRARY_ID, BUNNY_CDN_HOSTNAME, BUNNY_SIGNING_KEY],
  },
  async (request: CallableRequest<GetSignedUrlRequest>) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }

    const {courseId, lessonId, bunnyVideoId} = request.data ?? {};
    if (!courseId || !lessonId || !bunnyVideoId) {
      throw new HttpsError(
        "invalid-argument",
        "courseId, lessonId, and bunnyVideoId are required."
      );
    }

    // Free-preview lessons skip the entitlement check. The lesson document
    // marks itself as `isFreePreview: true` in Firestore.
    const lessonSnap = await db
      .doc(`courses/${courseId}/lessons/${lessonId}`)
      .get();
    if (!lessonSnap.exists) {
      throw new HttpsError("not-found", "Lesson not found.");
    }
    const isFreePreview = lessonSnap.data()?.isFreePreview === true;

    if (!isFreePreview) {
      const entSnap = await db.collection("entitlements").doc(uid).get();
      const courseIds: string[] = entSnap.exists
        ? (entSnap.data()?.courseIds as string[]) ?? []
        : [];
      if (!courseIds.includes(courseId)) {
        throw new HttpsError(
          "permission-denied",
          "You haven't unlocked this course yet."
        );
      }
    }

    // Build the token-authenticated Bunny URL.
    //
    //   tokenPath = "/<videoGuid>/playlist.m3u8"
    //   expires   = now + 1 hour
    //   raw       = signingKey + tokenPath + expires
    //   token     = base64url( sha256_bytes(raw) )
    //   url       = "https://${cdnHost}${tokenPath}"
    //               "?token=${token}&expires=${expires}"
    //
    // Reference:
    //   https://docs.bunny.net/docs/stream-embedding-videos-token-authentication
    const cdnHost = BUNNY_CDN_HOSTNAME.value();
    const signingKey = BUNNY_SIGNING_KEY.value();
    const tokenPath = `/${bunnyVideoId}/playlist.m3u8`;
    const expires = Math.floor(Date.now() / 1000) + 60 * 60;
    const raw = `${signingKey}${tokenPath}${expires}`;
    const token = createHash("sha256")
      .update(raw)
      .digest("base64")
      .replaceAll("+", "-")
      .replaceAll("/", "_")
      .replaceAll("=", "");

    const url =
      `https://${cdnHost}${tokenPath}?token=${token}&expires=${expires}`;

    return {url, expiresAt: expires * 1000};
  }
);
