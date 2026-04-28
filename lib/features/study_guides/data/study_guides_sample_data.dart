import '../domain/study_guide.dart';

/// Sample data for the الملازم store. Mirrors `SampleData.courses` for
/// the courses store but lives in its own namespace.
abstract final class StudyGuidesData {
  /// Public PDF stand-in until Firebase Storage is wired.
  static const _samplePdf =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

  static const guides = [
    StudyGuide(
      id: 'g_math_summary',
      title: 'ملخص الرياضيات — السادس العلمي',
      subject: 'الرياضيات',
      author: 'الأستاذ أحمد العبيدي',
      pageCount: 84,
      sizeBytes: 4_200_000,
      priceIqd: 7000,
      isLocked: true,
      description:
          'ملخص شامل يغطي كل فصول السادس العلمي: التفاضل والتكامل، '
          'الجبر والمتباينات، الاحتمالية والإحصاء. يتضمن ملاحظات هامة، '
          'أمثلة محلولة، وقواعد سريعة الحفظ.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_math_problems',
      title: 'بنك أسئلة الرياضيات (٥٠٠+ مسألة)',
      subject: 'الرياضيات',
      author: 'الأستاذ مصطفى البياتي',
      pageCount: 156,
      sizeBytes: 7_800_000,
      priceIqd: 10000,
      isLocked: true,
      description:
          'أكثر من ٥٠٠ مسألة مرتبة حسب الصعوبة، مع حل تفصيلي لكل مسألة. '
          'مثالي للمراجعة قبل الامتحانات الوزارية.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_phys_mechanics',
      title: 'ملزمة الميكانيك المصورة',
      subject: 'الفيزياء',
      author: 'الدكتورة ليلى الكاظمي',
      pageCount: 96,
      sizeBytes: 5_500_000,
      priceIqd: 8000,
      isLocked: true,
      description:
          'شرح مصور لقوانين نيوتن، الحركة، الشغل والطاقة، والزخم. '
          'يحتوي رسوم تخطيطية وحلول بأسلوب الخطوة-خطوة.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_phys_electricity',
      title: 'الكهربائية والمغناطيسية — مراجعة سريعة',
      subject: 'الفيزياء',
      author: 'الأستاذ حيدر الموسوي',
      pageCount: 72,
      sizeBytes: 3_900_000,
      priceIqd: 6000,
      isLocked: true,
      description:
          'مراجعة مكثفة لقوانين كولوم، أوم، كيرشوف، والحث الكهرومغناطيسي. '
          'مع جدول تلخيصي للقوانين والأبعاد الفيزيائية.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_bio_summary',
      title: 'ملخص الأحياء — السادس العلمي',
      subject: 'الأحياء',
      author: 'الدكتور كرار الزبيدي',
      pageCount: 110,
      sizeBytes: 6_200_000,
      priceIqd: 8000,
      isLocked: true,
      description:
          'ملخص متكامل لعلم الخلية، الوراثة، DNA، فسلجة الإنسان، والتطبيقات '
          'الحيوية. مدعوم برسوم بيانية.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_bio_diagrams',
      title: 'أطلس الأحياء — رسومات وزارية',
      subject: 'الأحياء',
      author: 'الأستاذة نور الشمري',
      pageCount: 64,
      sizeBytes: 9_400_000,
      priceIqd: 7000,
      isLocked: false,
      description:
          'مجموعة من الرسوم التشريحية والتخطيطية المتكررة في الأسئلة '
          'الوزارية مع شرح مختصر لكل رسم. (ملزمة مجانية كعينة)',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_ministerial_pack',
      title: 'الأسئلة الوزارية (٥ سنوات) — حلول كاملة',
      subject: 'مراجعة عامة',
      author: 'فريق المنصة',
      pageCount: 220,
      sizeBytes: 12_500_000,
      priceIqd: 15000,
      isLocked: true,
      description:
          'أسئلة الوزارة لخمس سنوات (٢٠٢٠ — ٢٠٢٤) في الرياضيات، الفيزياء، '
          'والأحياء، مع نموذج إجابة مفصّل لكل سؤال وتعليقات على الأخطاء '
          'الشائعة.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
  ];

  static StudyGuide? guideById(String id) {
    for (final g in guides) {
      if (g.id == id) return g;
    }
    return null;
  }

  static List<StudyGuide> guidesBySubject(String subject) =>
      guides.where((g) => g.subject == subject).toList();
}
