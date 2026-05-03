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
      label: 'كل كورسات الإعدادية',
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
    // ─── Engineering ────────────────────────────────────────────────────
    Coupon(
      code: 'ENG-MATH-2025',
      label: 'كوبون الرياضيات الهندسية',
      courseIds: ['c_eng_math1', 'c_eng_diff_eq'],
    ),
    Coupon(
      code: 'ENG-EE-2025',
      label: 'كوبون الكهرباء والإلكترونيات',
      courseIds: ['c_eng_circuits', 'c_eng_electronics'],
    ),
    Coupon(
      code: 'ENG-ALL-2025',
      label: 'كل كورسات الهندسة',
      courseIds: [
        'c_eng_math1',
        'c_eng_diff_eq',
        'c_eng_statics',
        'c_eng_circuits',
        'c_eng_electronics',
        'c_eng_cpp',
      ],
    ),
    // ─── Medical ────────────────────────────────────────────────────────
    Coupon(
      code: 'MED-ANAT-2025',
      label: 'كوبون كورسات التشريح',
      courseIds: ['c_med_anatomy_upper', 'c_med_anatomy_lower'],
    ),
    Coupon(
      code: 'MED-PHYS-2025',
      label: 'كوبون الفسلجة الطبية',
      courseIds: ['c_med_physiology'],
    ),
    Coupon(
      code: 'MED-ALL-2025',
      label: 'كل الكورسات الطبية',
      courseIds: [
        'c_med_anatomy_upper',
        'c_med_anatomy_lower',
        'c_med_physiology',
        'c_med_biochem',
        'c_med_pharma',
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
    'ALL2025',
    'ENG-ALL-2025',
    'MED-ALL-2025',
  ];
}
