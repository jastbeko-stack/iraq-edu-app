/// "ملزمة" — a downloadable study-guide PDF sold independently of courses.
///
/// Distinct from [Lesson] attachments: lessons' PDFs are *bundled* with a
/// course unlock; a [StudyGuide] is its own purchasable item with its own
/// activation coupon namespace.
class StudyGuide {
  const StudyGuide({
    required this.id,
    required this.title,
    required this.subject,
    required this.author,
    required this.pageCount,
    required this.sizeBytes,
    required this.priceIqd,
    required this.isLocked,
    this.coverUrl,
    this.description = '',
    this.previewPdfUrl,
    this.fullPdfUrl,
  });

  final String id;
  final String title;
  final String subject;
  final String author;
  final int pageCount;
  final int sizeBytes;
  final int priceIqd;
  final bool isLocked;
  final String? coverUrl;
  final String description;

  /// Public preview URL — first few pages, available without unlock.
  final String? previewPdfUrl;

  /// Full PDF URL. In production this comes from a signed Firebase Storage
  /// URL gated by entitlements. While the backend is deferred this is the
  /// same demo PDF for everyone.
  final String? fullPdfUrl;
}

/// A coupon that unlocks one or more study guides. Modeled separately from
/// course [Coupon] so the namespaces never collide — a course coupon must
/// not unlock a guide and vice versa.
class StudyGuideCoupon {
  const StudyGuideCoupon({
    required this.code,
    required this.guideIds,
    required this.label,
  });

  final String code;
  final List<String> guideIds;
  final String label;
}

/// Outcome of a study-guide-coupon redemption.
sealed class StudyGuideRedemptionResult {
  const StudyGuideRedemptionResult();
}

class StudyGuideRedemptionSuccess extends StudyGuideRedemptionResult {
  const StudyGuideRedemptionSuccess({
    required this.coupon,
    required this.newlyUnlocked,
  });

  final StudyGuideCoupon coupon;
  final List<String> newlyUnlocked;
}

class StudyGuideRedemptionInvalid extends StudyGuideRedemptionResult {
  const StudyGuideRedemptionInvalid();
}

class StudyGuideRedemptionAlreadyOwned extends StudyGuideRedemptionResult {
  const StudyGuideRedemptionAlreadyOwned({required this.coupon});

  final StudyGuideCoupon coupon;
}
