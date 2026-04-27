import 'coupon.dart';

/// Hardcoded set of valid coupons for the local-only demo.
///
/// Each subject has its own redemption code, plus an `ALL2025` master code
/// that unlocks every course. Replace this with a Firestore `coupons`
/// collection + Cloud Function transaction once the backend is wired.
abstract final class CouponCodes {
  static const List<Coupon> validCoupons = [
    Coupon(
      code: 'MATH2025',
      label: 'كوبون كورسات الرياضيات',
      courseIds: ['c_calculus', 'c_algebra', 'c_probability'],
    ),
    Coupon(
      code: 'PHYSICS2025',
      label: 'كوبون كورسات الفيزياء',
      courseIds: ['c_mechanics', 'c_electricity', 'c_waves'],
    ),
    Coupon(
      code: 'BIO2025',
      label: 'كوبون كورسات الأحياء',
      courseIds: ['c_cell_biology', 'c_human_physiology'],
    ),
    Coupon(
      code: 'CALC2025',
      label: 'كوبون كورس التفاضل والتكامل',
      courseIds: ['c_calculus'],
    ),
    Coupon(
      code: 'MECH2025',
      label: 'كوبون كورس الميكانيك',
      courseIds: ['c_mechanics'],
    ),
    Coupon(
      code: 'CELL2025',
      label: 'كوبون كورس علم الخلية',
      courseIds: ['c_cell_biology'],
    ),
    Coupon(
      code: 'ALL2025',
      label: 'الكوبون الشامل (كل الكورسات)',
      courseIds: [
        'c_calculus',
        'c_algebra',
        'c_probability',
        'c_mechanics',
        'c_electricity',
        'c_waves',
        'c_cell_biology',
        'c_human_physiology',
      ],
    ),
  ];

  /// Look up a coupon by its code (case- and whitespace-insensitive).
  static Coupon? lookup(String input) {
    final normalized = input.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    for (final c in validCoupons) {
      if (c.code == normalized) return c;
    }
    return null;
  }

  /// Demo codes shown as a hint inside the redemption sheet so reviewers can
  /// try the flow without a real backend.
  static const List<String> demoHintCodes = [
    'MATH2025',
    'PHYSICS2025',
    'BIO2025',
    'ALL2025',
  ];
}
