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
    required this.trackId,
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
  final String trackId;
  final String? coverUrl;
  final String description;

  /// Public preview URL — first few pages, available without unlock.
  final String? previewPdfUrl;

  /// Full PDF URL. In production this comes from a signed Firebase Storage
  /// URL gated by entitlements. While the backend is deferred this is the
  /// same demo PDF for everyone.
  final String? fullPdfUrl;

  StudyGuide copyWith({
    String? id,
    String? title,
    String? subject,
    String? author,
    int? pageCount,
    int? sizeBytes,
    int? priceIqd,
    bool? isLocked,
    String? trackId,
    String? coverUrl,
    String? description,
    String? previewPdfUrl,
    String? fullPdfUrl,
  }) => StudyGuide(
    id: id ?? this.id,
    title: title ?? this.title,
    subject: subject ?? this.subject,
    author: author ?? this.author,
    pageCount: pageCount ?? this.pageCount,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    priceIqd: priceIqd ?? this.priceIqd,
    isLocked: isLocked ?? this.isLocked,
    trackId: trackId ?? this.trackId,
    coverUrl: coverUrl ?? this.coverUrl,
    description: description ?? this.description,
    previewPdfUrl: previewPdfUrl ?? this.previewPdfUrl,
    fullPdfUrl: fullPdfUrl ?? this.fullPdfUrl,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'author': author,
    'pageCount': pageCount,
    'sizeBytes': sizeBytes,
    'priceIqd': priceIqd,
    'isLocked': isLocked,
    'trackId': trackId,
    'coverUrl': coverUrl,
    'description': description,
    'previewPdfUrl': previewPdfUrl,
    'fullPdfUrl': fullPdfUrl,
  };

  factory StudyGuide.fromJson(Map<String, dynamic> json) => StudyGuide(
    id: json['id'] as String,
    title: json['title'] as String,
    subject: json['subject'] as String,
    author: json['author'] as String,
    pageCount: json['pageCount'] as int,
    sizeBytes: json['sizeBytes'] as int,
    priceIqd: json['priceIqd'] as int,
    isLocked: json['isLocked'] as bool,
    trackId: json['trackId'] as String,
    coverUrl: json['coverUrl'] as String?,
    description: (json['description'] as String?) ?? '',
    previewPdfUrl: json['previewPdfUrl'] as String?,
    fullPdfUrl: json['fullPdfUrl'] as String?,
  );
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

  Map<String, dynamic> toJson() => {
    'code': code,
    'guideIds': guideIds,
    'label': label,
  };

  factory StudyGuideCoupon.fromJson(Map<String, dynamic> json) =>
      StudyGuideCoupon(
        code: json['code'] as String,
        guideIds: (json['guideIds'] as List<dynamic>).cast<String>(),
        label: json['label'] as String,
      );
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
