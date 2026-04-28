import 'study_guide.dart';

/// Hardcoded valid study-guide coupons for the no-backend demo phase.
///
/// Note the `G` prefix — keeps the namespace cleanly separate from course
/// codes (`MATH2025`, `PHYSICS2025`, etc.) so a student can never
/// accidentally redeem the wrong store's coupon and unlock the wrong items.
abstract final class StudyGuideCodes {
  static const validCoupons = [
    StudyGuideCoupon(
      code: 'G-MATH-2025',
      guideIds: ['g_math_summary', 'g_math_problems'],
      label: 'حزمة ملازم الرياضيات',
    ),
    StudyGuideCoupon(
      code: 'G-PHYS-2025',
      guideIds: ['g_phys_mechanics', 'g_phys_electricity'],
      label: 'حزمة ملازم الفيزياء',
    ),
    StudyGuideCoupon(
      code: 'G-BIO-2025',
      guideIds: ['g_bio_summary', 'g_bio_diagrams'],
      label: 'حزمة ملازم الأحياء',
    ),
    StudyGuideCoupon(
      code: 'G-MINISTERIAL-2025',
      guideIds: ['g_ministerial_pack'],
      label: 'حزمة الأسئلة الوزارية',
    ),
    StudyGuideCoupon(
      code: 'G-ALL-2025',
      guideIds: [
        'g_math_summary',
        'g_math_problems',
        'g_phys_mechanics',
        'g_phys_electricity',
        'g_bio_summary',
        'g_bio_diagrams',
        'g_ministerial_pack',
      ],
      label: 'كل الملازم — الباقة الكاملة',
    ),
  ];

  static StudyGuideCoupon? lookup(String code) {
    final normalized = code.trim().toUpperCase();
    for (final c in validCoupons) {
      if (c.code.toUpperCase() == normalized) return c;
    }
    return null;
  }

  /// Codes shown as tap-to-fill chips inside the redemption sheet so the
  /// user can try the flow without typing.
  static const demoHintCodes = [
    'G-ALL-2025',
    'G-BIO-2025',
    'G-PHYS-2025',
    'G-MATH-2025',
  ];
}
