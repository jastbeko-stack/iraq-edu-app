/// A coupon definition.
///
/// In production these will live in Firestore (`coupons` collection) and the
/// redemption flow will be a Cloud Function transaction. For the local-only
/// demo, [validCoupons] below is a hardcoded set so reviewers can try the UX
/// without a backend.
class Coupon {
  const Coupon({
    required this.code,
    required this.courseIds,
    required this.label,
  });

  /// The redeemable code (case-insensitive when matching).
  final String code;

  /// Course ids unlocked by this coupon. A "master" coupon can unlock many.
  final List<String> courseIds;

  /// Human-readable label shown on success.
  final String label;

  Map<String, dynamic> toJson() => {
    'code': code,
    'courseIds': courseIds,
    'label': label,
  };

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    code: json['code'] as String,
    courseIds: (json['courseIds'] as List<dynamic>).cast<String>(),
    label: json['label'] as String,
  );
}

/// Outcome of a redemption attempt.
sealed class CouponRedemptionResult {
  const CouponRedemptionResult();
}

class CouponRedemptionSuccess extends CouponRedemptionResult {
  const CouponRedemptionSuccess({
    required this.coupon,
    required this.newlyUnlocked,
  });

  final Coupon coupon;

  /// Course ids that became unlocked from this redemption (excludes courses
  /// the user already had).
  final List<String> newlyUnlocked;
}

class CouponRedemptionInvalid extends CouponRedemptionResult {
  const CouponRedemptionInvalid();
}

class CouponRedemptionAlreadyOwned extends CouponRedemptionResult {
  const CouponRedemptionAlreadyOwned({required this.coupon});

  final Coupon coupon;
}
