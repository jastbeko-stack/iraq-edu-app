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
      label: 'ملازم الإعدادية — الباقة الكاملة',
    ),
    // ─── Engineering ────────────────────────────────────────────────────
    StudyGuideCoupon(
      code: 'G-ENG-MATH-2025',
      guideIds: ['g_eng_math1', 'g_eng_diff_eq'],
      label: 'ملازم الرياضيات الهندسية',
    ),
    StudyGuideCoupon(
      code: 'G-ENG-ALL-2025',
      guideIds: [
        'g_eng_math1',
        'g_eng_diff_eq',
        'g_eng_statics',
        'g_eng_circuits',
        'g_eng_cpp',
      ],
      label: 'ملازم الهندسة — الباقة الكاملة',
    ),
    // ─── Medical ────────────────────────────────────────────────────────
    StudyGuideCoupon(
      code: 'G-MED-ANAT-2025',
      guideIds: ['g_med_anatomy_atlas'],
      label: 'أطلس التشريح الطبي',
    ),
    StudyGuideCoupon(
      code: 'G-MED-ALL-2025',
      guideIds: [
        'g_med_anatomy_atlas',
        'g_med_physiology_summary',
        'g_med_biochem_pathways',
        'g_med_pharma_quick',
      ],
      label: 'ملازم الكليات الطبية — الباقة الكاملة',
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
    'G-ENG-ALL-2025',
    'G-MED-ALL-2025',
  ];
}
