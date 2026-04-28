import 'course.dart';
import 'teacher.dart';

/// Realistic 6th Scientific (السادس العلمي) sample data for Math, Physics,
/// and Biology — the three subjects the user prioritized.
///
/// All data is in-memory for the no-backend phase. When Firestore is wired
/// up, replace these lookups with a repository that exposes the same shapes.
abstract final class SampleData {
  static const List<Teacher> teachers = [
    // ─── Math ─────────────────────────────────────────────────────────────
    Teacher(
      id: 't_ahmed_obeidi',
      name: 'الأستاذ أحمد العبيدي',
      subject: 'الرياضيات',
      bio:
          'مدرس رياضيات للسادس العلمي بخبرة 14 سنة في تدريس مادة التفاضل '
          'والتكامل والجبر. حاصل على البكالوريوس في الرياضيات من جامعة '
          'بغداد. أسلوبه يعتمد على شرح الفكرة الأساسية أولاً ثم حل أسئلة '
          'وزارية متدرجة الصعوبة.',
      coursesCount: 2,
      studentsCount: 1820,
    ),
    Teacher(
      id: 't_mustafa_bayati',
      name: 'الأستاذ مصطفى البياتي',
      subject: 'الرياضيات',
      bio:
          'متخصص في الاحتمالية والإحصاء والمتسلسلات. خريج كلية التربية — '
          'ابن الهيثم، يهتم بربط الرياضيات بالحياة اليومية ليسهل فهمها على '
          'الطلاب.',
      coursesCount: 1,
      studentsCount: 940,
    ),

    // ─── Physics ──────────────────────────────────────────────────────────
    Teacher(
      id: 't_layla_kadhimi',
      name: 'الدكتورة ليلى الكاظمي',
      subject: 'الفيزياء',
      bio:
          'دكتوراه في الفيزياء من الجامعة المستنصرية. تشرح الميكانيك '
          'والفيزياء الحرارية بطريقة قصصية مع أمثلة من الواقع، وتركّز على '
          'فهم القوانين قبل حفظها.',
      coursesCount: 1,
      studentsCount: 1340,
    ),
    Teacher(
      id: 't_haider_mousawi',
      name: 'الأستاذ حيدر الموسوي',
      subject: 'الفيزياء',
      bio:
          'مدرس فيزياء بخبرة 11 سنة، متخصص في فصول الكهربائية والمغناطيسية '
          'والموجات. معروف بحل الأسئلة الوزارية للسنوات العشر الأخيرة في '
          'كورساته.',
      coursesCount: 2,
      studentsCount: 1520,
    ),

    // ─── Biology ──────────────────────────────────────────────────────────
    Teacher(
      id: 't_karrar_zubaidi',
      name: 'الدكتور كرار الزبيدي',
      subject: 'علم الأحياء',
      bio:
          'دكتوراه في علم الخلية والوراثة من جامعة بغداد. يبسط المفاهيم '
          'المعقدة باستخدام الرسومات والمخططات، ويركز على الاسئلة الوزارية '
          'وأسئلة المراجعة المركزة.',
      coursesCount: 1,
      studentsCount: 1100,
    ),
    Teacher(
      id: 't_noor_shamri',
      name: 'الأستاذة نور الشمري',
      subject: 'علم الأحياء',
      bio:
          'مدرسة أحياء متخصصة في فسلجة الإنسان والأجهزة الحيوية. خبرتها 9 '
          'سنوات في تدريس السادس العلمي وإعداد الطلاب لامتحان البكلوريا.',
      coursesCount: 1,
      studentsCount: 870,
    ),
  ];

  static const List<Course> courses = [
    // ─── Math ─────────────────────────────────────────────────────────────
    Course(
      id: 'c_calculus',
      title: 'التفاضل والتكامل — السادس العلمي',
      teacherId: 't_ahmed_obeidi',
      teacherName: 'الأستاذ أحمد العبيدي',
      subject: 'الرياضيات',
      lessonsCount: 24,
      isLocked: true,
      description:
          'كورس شامل يغطي فصول النهايات والاتصال، المشتقة وتطبيقاتها، '
          'التكامل المحدد وغير المحدد، وتطبيقات التكامل. يتضمن حل '
          'الأسئلة الوزارية للسنوات الخمس الأخيرة.',
    ),
    Course(
      id: 'c_algebra',
      title: 'الجبر والمتباينات والاقترانات',
      teacherId: 't_ahmed_obeidi',
      teacherName: 'الأستاذ أحمد العبيدي',
      subject: 'الرياضيات',
      lessonsCount: 18,
      isLocked: true,
      description:
          'مراجعة سريعة لأساسيات الجبر مع التركيز على الأقسام التي تظهر '
          'في الامتحان الوزاري: الاقترانات، المتباينات، اللوغاريتمات.',
    ),
    Course(
      id: 'c_probability',
      title: 'الاحتمالية والإحصاء',
      teacherId: 't_mustafa_bayati',
      teacherName: 'الأستاذ مصطفى البياتي',
      subject: 'الرياضيات',
      lessonsCount: 14,
      isLocked: true,
      description:
          'يغطي مفاهيم الاحتمال، التوزيعات، الإحصاء الوصفي، ومقاييس '
          'النزعة المركزية والتشتت، مع تطبيقات على بيانات حقيقية.',
    ),

    // ─── Physics ──────────────────────────────────────────────────────────
    Course(
      id: 'c_mechanics',
      title: 'الميكانيك الكلاسيكي',
      teacherId: 't_layla_kadhimi',
      teacherName: 'الدكتورة ليلى الكاظمي',
      subject: 'الفيزياء',
      lessonsCount: 20,
      isLocked: true,
      description:
          'يبدأ بقوانين نيوتن وينتهي بالحركة الدورانية والهزاز التوافقي '
          'البسيط. كل درس يحتوي على أمثلة محلولة وأسئلة وزارية ومراجعة.',
    ),
    Course(
      id: 'c_electricity',
      title: 'الكهربائية والمغناطيسية',
      teacherId: 't_haider_mousawi',
      teacherName: 'الأستاذ حيدر الموسوي',
      subject: 'الفيزياء',
      lessonsCount: 22,
      isLocked: true,
      description:
          'فصول الكهربائية الساكنة، التيار الكهربائي، الدوائر الكهربائية، '
          'المجال المغناطيسي، والحث الكهرومغناطيسي. مع شرح مفصل لأسئلة '
          'البكلوريا.',
    ),
    Course(
      id: 'c_waves',
      title: 'الموجات والصوت والضوء',
      teacherId: 't_haider_mousawi',
      teacherName: 'الأستاذ حيدر الموسوي',
      subject: 'الفيزياء',
      lessonsCount: 16,
      isLocked: false,
      description:
          'مدخل إلى الحركة الموجية، الموجات الميكانيكية، الموجات الصوتية، '
          'وخصائص الضوء. مع تطبيقات على الظواهر اليومية.',
    ),

    // ─── Biology ──────────────────────────────────────────────────────────
    Course(
      id: 'c_cell_biology',
      title: 'علم الخلية والوراثة',
      teacherId: 't_karrar_zubaidi',
      teacherName: 'الدكتور كرار الزبيدي',
      subject: 'علم الأحياء',
      lessonsCount: 19,
      isLocked: true,
      description:
          'يغطي تركيب الخلية وعضياتها، الانقسام الخلوي بنوعيه، علم '
          'الوراثة المندلية، الـ DNA و RNA، والهندسة الوراثية. يتضمن '
          'مخططات توضيحية لكل درس.',
    ),
    Course(
      id: 'c_human_physiology',
      title: 'فسلجة الإنسان والأجهزة الحيوية',
      teacherId: 't_noor_shamri',
      teacherName: 'الأستاذة نور الشمري',
      subject: 'علم الأحياء',
      lessonsCount: 17,
      isLocked: true,
      description:
          'الجهاز الهضمي، الدوري، التنفسي، البولي، العصبي، والتناسلي. '
          'شرح مفصل بالرسومات مع التركيز على الأسئلة الوزارية المتكررة.',
    ),
  ];

  /// Lessons keyed by course id. Replace with Firestore subcollection
  /// `courses/{courseId}/lessons` later. The first lesson of each course is
  /// always a free preview so students can sample the teaching style.
  static const Map<String, List<Lesson>> lessonsByCourseId = {
    // Calculus
    'c_calculus': [
      Lesson(
        id: 'l1',
        title: 'مقدمة الكورس وخطة الدراسة',
        durationMinutes: 8,
        isFreePreview: true,
      ),
      Lesson(
        id: 'l2',
        title: 'النهايات — المفهوم والقواعد',
        durationMinutes: 26,
      ),
      Lesson(id: 'l3', title: 'الاتصال وعدم الاتصال', durationMinutes: 22),
      Lesson(
        id: 'l4',
        title: 'المشتقة — التعريف والقواعد',
        durationMinutes: 32,
      ),
      Lesson(
        id: 'l5',
        title: 'تطبيقات المشتقة (القيم القصوى)',
        durationMinutes: 28,
      ),
      Lesson(id: 'l6', title: 'التكامل غير المحدد', durationMinutes: 24),
      Lesson(
        id: 'l7',
        title: 'التكامل المحدد ومساحة المنطقة',
        durationMinutes: 30,
      ),
      Lesson(id: 'l8', title: 'مراجعة الأسئلة الوزارية', durationMinutes: 45),
    ],
    // Algebra
    'c_algebra': [
      Lesson(
        id: 'l1',
        title: 'مقدمة الكورس',
        durationMinutes: 6,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'الاقترانات وأنواعها', durationMinutes: 24),
      Lesson(
        id: 'l3',
        title: 'المتباينات الخطية والتربيعية',
        durationMinutes: 26,
      ),
      Lesson(id: 'l4', title: 'الأسس واللوغاريتمات', durationMinutes: 28),
      Lesson(id: 'l5', title: 'حل الأسئلة الوزارية', durationMinutes: 35),
    ],
    // Probability
    'c_probability': [
      Lesson(
        id: 'l1',
        title: 'مقدمة في الاحتمال',
        durationMinutes: 10,
        isFreePreview: true,
      ),
      Lesson(
        id: 'l2',
        title: 'قواعد الاحتمال والاحتمال الشرطي',
        durationMinutes: 24,
      ),
      Lesson(id: 'l3', title: 'التوزيعات الاحتمالية', durationMinutes: 22),
      Lesson(id: 'l4', title: 'مقاييس النزعة المركزية', durationMinutes: 20),
      Lesson(
        id: 'l5',
        title: 'مقاييس التشتت والانحراف المعياري',
        durationMinutes: 22,
      ),
    ],
    // Mechanics
    'c_mechanics': [
      Lesson(
        id: 'l1',
        title: 'مقدمة الميكانيك وقوانين نيوتن',
        durationMinutes: 12,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'الحركة في خط مستقيم', durationMinutes: 26),
      Lesson(id: 'l3', title: 'الشغل والطاقة والقدرة', durationMinutes: 30),
      Lesson(id: 'l4', title: 'الزخم الخطي والاندفاع', durationMinutes: 28),
      Lesson(id: 'l5', title: 'الحركة الدورانية', durationMinutes: 32),
      Lesson(id: 'l6', title: 'الهزاز التوافقي البسيط', durationMinutes: 24),
      Lesson(id: 'l7', title: 'مراجعة وزاريات الميكانيك', durationMinutes: 40),
    ],
    // Electricity
    'c_electricity': [
      Lesson(
        id: 'l1',
        title: 'مقدمة الكهربائية الساكنة',
        durationMinutes: 10,
        isFreePreview: true,
      ),
      Lesson(
        id: 'l2',
        title: 'قانون كولوم والمجال الكهربائي',
        durationMinutes: 28,
      ),
      Lesson(id: 'l3', title: 'الجهد والسعة الكهربائية', durationMinutes: 26),
      Lesson(
        id: 'l4',
        title: 'التيار الكهربائي وقانون أوم',
        durationMinutes: 24,
      ),
      Lesson(
        id: 'l5',
        title: 'الدوائر الكهربائية وقوانين كيرشوف',
        durationMinutes: 32,
      ),
      Lesson(id: 'l6', title: 'المجال المغناطيسي', durationMinutes: 26),
      Lesson(id: 'l7', title: 'الحث الكهرومغناطيسي', durationMinutes: 28),
    ],
    // Waves
    'c_waves': [
      Lesson(
        id: 'l1',
        title: 'مقدمة الحركة الموجية',
        durationMinutes: 10,
        isFreePreview: true,
      ),
      Lesson(
        id: 'l2',
        title: 'الموجات الميكانيكية وخصائصها',
        durationMinutes: 24,
      ),
      Lesson(
        id: 'l3',
        title: 'الموجات الصوتية وظاهرة دوبلر',
        durationMinutes: 26,
      ),
      Lesson(id: 'l4', title: 'انعكاس الضوء وانكساره', durationMinutes: 22),
      Lesson(id: 'l5', title: 'تداخل الضوء وحيود الضوء', durationMinutes: 28),
    ],
    // Cell Biology
    'c_cell_biology': [
      Lesson(
        id: 'l1',
        title: 'مقدمة عن الخلية وأنواعها',
        durationMinutes: 12,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'العضيات الخلوية ووظائفها', durationMinutes: 26),
      Lesson(id: 'l3', title: 'الانقسام الميتوزي', durationMinutes: 22),
      Lesson(id: 'l4', title: 'الانقسام الميوزي', durationMinutes: 24),
      Lesson(id: 'l5', title: 'علم الوراثة المندلية', durationMinutes: 28),
      Lesson(
        id: 'l6',
        title: 'الـ DNA و RNA والشيفرة الوراثية',
        durationMinutes: 30,
      ),
      Lesson(
        id: 'l7',
        title: 'الهندسة الوراثية والتطبيقات',
        durationMinutes: 26,
      ),
    ],
    // Human Physiology
    'c_human_physiology': [
      Lesson(
        id: 'l1',
        title: 'مقدمة فسلجة الإنسان',
        durationMinutes: 10,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'الجهاز الهضمي', durationMinutes: 26),
      Lesson(id: 'l3', title: 'الجهاز الدوري والقلب', durationMinutes: 28),
      Lesson(id: 'l4', title: 'الجهاز التنفسي', durationMinutes: 22),
      Lesson(id: 'l5', title: 'الجهاز البولي', durationMinutes: 20),
      Lesson(id: 'l6', title: 'الجهاز العصبي والحواس', durationMinutes: 30),
      Lesson(id: 'l7', title: 'الجهاز التناسلي', durationMinutes: 24),
    ],
  };

  static Teacher? teacherById(String id) {
    for (final t in teachers) {
      if (t.id == id) return t;
    }
    return null;
  }

  static Course? courseById(String id) {
    for (final c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<Course> coursesByTeacher(String teacherId) =>
      courses.where((c) => c.teacherId == teacherId).toList();

  /// Public sample MP4 used as the playback URL for every lesson while
  /// Bunny.net + Cloud Functions are deferred. This is the Flutter team's
  /// own sample asset (CORS-enabled, served over HTTPS) so it works in
  /// iOS Safari, Android, and Chrome without a streaming shim.
  static const _sampleVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  /// Small public PDF stand-in for lesson worksheets / summaries. Replace
  /// with Firebase Storage URLs once the backend lands.
  static const _samplePdfUrl =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

  /// Returns lessons for a course with the demo `previewVideoUrl` and a
  /// realistic set of attachments attached. Free-preview lessons get a
  /// lighter attachment set (just a syllabus); the deep-review lesson at
  /// the end of each course gets a "ministerial pack" PDF bundle.
  static List<Lesson> lessonsForCourse(String courseId) {
    final raw = lessonsByCourseId[courseId];
    if (raw == null) return const [];
    return [
      for (final l in raw)
        Lesson(
          id: l.id,
          title: l.title,
          durationMinutes: l.durationMinutes,
          isFreePreview: l.isFreePreview,
          bunnyVideoId: l.bunnyVideoId,
          previewVideoUrl: l.previewVideoUrl ?? _sampleVideoUrl,
          attachments: l.attachments.isNotEmpty
              ? l.attachments
              : _attachmentsFor(l),
        ),
    ];
  }

  static List<LessonAttachment> _attachmentsFor(Lesson l) {
    if (l.isFreePreview) {
      return const [
        LessonAttachment(
          id: 'a_syllabus',
          title: 'منهج الكورس الكامل',
          url: _samplePdfUrl,
          kind: AttachmentKind.pdf,
          sizeBytes: 180 * 1024,
        ),
      ];
    }
    final isReview = l.title.contains('مراجعة');
    return [
      const LessonAttachment(
        id: 'a_summary',
        title: 'ملخص الدرس',
        url: _samplePdfUrl,
        kind: AttachmentKind.pdf,
        sizeBytes: 420 * 1024,
      ),
      const LessonAttachment(
        id: 'a_worksheet',
        title: 'ورقة تمارين',
        url: _samplePdfUrl,
        kind: AttachmentKind.worksheet,
        sizeBytes: 280 * 1024,
      ),
      if (isReview)
        const LessonAttachment(
          id: 'a_ministerial_pack',
          title: 'حزمة أسئلة وزارية (٥ سنوات)',
          url: _samplePdfUrl,
          kind: AttachmentKind.notes,
          sizeBytes: 1200 * 1024,
        ),
    ];
  }
}
