import '../domain/study_guide.dart';

/// Sample data for the الملازم store. Mirrors `SampleData.courses` for
/// the courses store but lives in its own namespace.
abstract final class StudyGuidesData {
  static const _kPrep = 'preparatory';
  static const _kEng = 'engineering';
  static const _kMed = 'medical';

  /// Public PDF stand-in until Firebase Storage is wired.
  static const _samplePdf =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

  static const guides = [
    // ─── Preparatory ────────────────────────────────────────────────────
    StudyGuide(
      id: 'g_math_summary',
      title: 'ملخص الرياضيات — السادس العلمي',
      subject: 'الرياضيات',
      author: 'الأستاذ أحمد العبيدي',
      pageCount: 84,
      sizeBytes: 4_200_000,
      priceIqd: 7000,
      isLocked: true,
      trackId: _kPrep,
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
      trackId: _kPrep,
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
      trackId: _kPrep,
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
      trackId: _kPrep,
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
      trackId: _kPrep,
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
      trackId: _kPrep,
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
      trackId: _kPrep,
      description:
          'أسئلة الوزارة لخمس سنوات (٢٠٢٠ — ٢٠٢٤) في الرياضيات، الفيزياء، '
          'والأحياء، مع نموذج إجابة مفصّل لكل سؤال وتعليقات على الأخطاء '
          'الشائعة.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),

    // ─── Engineering ────────────────────────────────────────────────────
    StudyGuide(
      id: 'g_eng_math1',
      title: 'ملخص الرياضيات الهندسية I',
      subject: 'الرياضيات الهندسية',
      author: 'الدكتور علي الجبوري',
      pageCount: 132,
      sizeBytes: 6_800_000,
      priceIqd: 9000,
      isLocked: true,
      trackId: _kEng,
      description:
          'ملخص متكامل لمقرر Engineering Math I مع تركيز على المسائل '
          'الامتحانية: التحليل، المصفوفات، الفضاءات المتجهة.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_eng_diff_eq',
      title: 'بنك أسئلة المعادلات التفاضلية',
      subject: 'الرياضيات الهندسية',
      author: 'الدكتور علي الجبوري',
      pageCount: 88,
      sizeBytes: 4_900_000,
      priceIqd: 7000,
      isLocked: true,
      trackId: _kEng,
      description:
          'أكثر من 200 مسألة معادلات تفاضلية مع حل مفصّل، شاملة لتحويل '
          'لابلاس وتطبيقات الدوائر والميكانيك.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_eng_statics',
      title: 'ملخص الستاتيك مع مسائل امتحانية',
      subject: 'الميكانيك التطبيقي',
      author: 'الدكتورة زهراء العنبري',
      pageCount: 102,
      sizeBytes: 5_700_000,
      priceIqd: 8000,
      isLocked: true,
      trackId: _kEng,
      description:
          'يغطي الاتزان، الجمالونات، الإطارات، والاحتكاك. مع 60 مسألة '
          'امتحانية محلولة من جامعات عراقية.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_eng_circuits',
      title: 'ملزمة الدوائر الكهربائية I',
      subject: 'الدوائر الكهربائية',
      author: 'المهندس عمر النجار',
      pageCount: 118,
      sizeBytes: 6_100_000,
      priceIqd: 8000,
      isLocked: true,
      trackId: _kEng,
      description:
          'كيرشوف، تحليل العقد والحلقات، الدوائر الزمنية، AC. مع جدول '
          'صيغ سريعة المراجعة قبل الامتحانات.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_eng_cpp',
      title: 'دليل البرمجة بـ C++ مع مسائل',
      subject: 'البرمجة الهندسية',
      author: 'الدكتور ياسين الدليمي',
      pageCount: 152,
      sizeBytes: 7_200_000,
      priceIqd: 9000,
      isLocked: false,
      trackId: _kEng,
      description:
          'دليل مرجعي للسنة الأولى الهندسية في الـ C++ مع 80 مسألة '
          'برمجية متدرجة الصعوبة. (ملزمة مجانية كعينة)',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),

    // ─── Medical ────────────────────────────────────────────────────────
    StudyGuide(
      id: 'g_med_anatomy_atlas',
      title: 'أطلس التشريح — الأطراف والصدر',
      subject: 'علم التشريح',
      author: 'الدكتور حسن التميمي',
      pageCount: 184,
      sizeBytes: 14_500_000,
      priceIqd: 12000,
      isLocked: true,
      trackId: _kMed,
      description:
          'أطلس مصور بكامله بالألوان للأطراف العلوية والسفلية والصدر، '
          'مع علامات سريرية لكل صورة.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_med_physiology_summary',
      title: 'ملخص الفسلجة الطبية',
      subject: 'الفسلجة الطبية',
      author: 'الدكتورة رشا القيسي',
      pageCount: 142,
      sizeBytes: 7_900_000,
      priceIqd: 10000,
      isLocked: true,
      trackId: _kMed,
      description:
          'ملخص متكامل للفسلجة الطبية للسنة الأولى الطب: القلب، التنفس، '
          'الكلى، الجهاز العصبي والهرموني — مع حالات إكلينيكية.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_med_biochem_pathways',
      title: 'مخططات المسارات الأيضية (Biochem)',
      subject: 'الكيمياء الحيوية',
      author: 'الدكتور يوسف السعدي',
      pageCount: 76,
      sizeBytes: 5_300_000,
      priceIqd: 8000,
      isLocked: true,
      trackId: _kMed,
      description:
          'مخططات منظمة للـ Glycolysis، دورة كريبس، أيض الدهون، '
          'وأيض الأحماض الأمينية. مرتبة بطريقة سهلة الحفظ.',
      previewPdfUrl: _samplePdf,
      fullPdfUrl: _samplePdf,
    ),
    StudyGuide(
      id: 'g_med_pharma_quick',
      title: 'دليل الأدوية السريع',
      subject: 'علم الأدوية',
      author: 'الدكتورة دينا الهاشمي',
      pageCount: 68,
      sizeBytes: 3_400_000,
      priceIqd: 7000,
      isLocked: true,
      trackId: _kMed,
      description:
          'مرجع جيب لأشهر 100 دواء مع الجرعات، التداخلات، والآثار '
          'الجانبية. مفيد لطلاب الصيدلة والطب.',
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
