import 'course.dart';
import 'teacher.dart';

/// Realistic sample data spanning all three tracks
/// (preparatory / engineering / medical). All data is in-memory for the
/// no-backend phase; replace lookups with a Firestore-backed repository
/// later — keep the model classes stable so the UI doesn't change.
abstract final class SampleData {
  static const _kPrep = 'preparatory';
  static const _kEng = 'engineering';
  static const _kMed = 'medical';

  static const List<Teacher> teachers = [
    // ─── Preparatory: Math ────────────────────────────────────────────────
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
      trackId: _kPrep,
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
      trackId: _kPrep,
    ),
    // ─── Preparatory: Physics ────────────────────────────────────────────
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
      trackId: _kPrep,
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
      trackId: _kPrep,
    ),
    // ─── Preparatory: Biology ────────────────────────────────────────────
    Teacher(
      id: 't_karrar_zubaidi',
      name: 'الدكتور كرار الزبيدي',
      subject: 'علم الأحياء',
      bio:
          'دكتوراه في علم الخلية والوراثة من جامعة بغداد. يبسط المفاهيم '
          'المعقدة باستخدام الرسومات والمخططات، ويركز على الأسئلة الوزارية '
          'وأسئلة المراجعة المركزة.',
      coursesCount: 1,
      studentsCount: 1100,
      trackId: _kPrep,
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
      trackId: _kPrep,
    ),

    // ─── Engineering ────────────────────────────────────────────────────
    Teacher(
      id: 't_eng_ali_jubouri',
      name: 'الدكتور علي الجبوري',
      subject: 'الرياضيات الهندسية',
      bio:
          'أستاذ مساعد في الجامعة التكنولوجية. متخصص في التحليل الرياضي، '
          'المعادلات التفاضلية، والجبر الخطي لطلاب المرحلة الأولى '
          'الهندسية.',
      coursesCount: 2,
      studentsCount: 980,
      trackId: _kEng,
    ),
    Teacher(
      id: 't_eng_zahraa_anbari',
      name: 'الدكتورة زهراء العنبري',
      subject: 'الميكانيك التطبيقي',
      bio:
          'دكتوراه في الهندسة الميكانيكية من جامعة بغداد، تركّز على '
          'الستاتيك والديناميك لطلاب الهندسة المدنية والميكانيكية.',
      coursesCount: 1,
      studentsCount: 640,
      trackId: _kEng,
    ),
    Teacher(
      id: 't_eng_omar_najjar',
      name: 'المهندس عمر النجار',
      subject: 'الدوائر الكهربائية',
      bio:
          'مهندس كهرباء وأستاذ في كلية الهندسة — قسم الإلكترونيات. خبرته '
          '12 سنة في تدريس الدوائر الكهربائية والإلكترونيات الرقمية.',
      coursesCount: 2,
      studentsCount: 720,
      trackId: _kEng,
    ),
    Teacher(
      id: 't_eng_yasin_dulaimi',
      name: 'الدكتور ياسين الدليمي',
      subject: 'البرمجة الهندسية',
      bio:
          'أستاذ في كلية الهندسة قسم الحاسبات. يدرّس مقدمة البرمجة، C++، '
          'وأساسيات هياكل البيانات لطلاب السنة الأولى.',
      coursesCount: 1,
      studentsCount: 560,
      trackId: _kEng,
    ),

    // ─── Medical ────────────────────────────────────────────────────────
    Teacher(
      id: 't_med_hassan_tamimi',
      name: 'الدكتور حسن التميمي',
      subject: 'علم التشريح',
      bio:
          'دكتوراه في التشريح من كلية الطب بجامعة بغداد. خبرة 16 سنة في '
          'تدريس Gross Anatomy و Histology لطلاب المرحلة الأولى الطب.',
      coursesCount: 2,
      studentsCount: 1240,
      trackId: _kMed,
    ),
    Teacher(
      id: 't_med_rasha_qaisi',
      name: 'الدكتورة رشا القيسي',
      subject: 'الفسلجة الطبية',
      bio:
          'استشارية فسلجة طبية وأستاذة مساعدة. تربط الفسلجة بالحالات '
          'الإكلينيكية كي يفهم الطالب الوظيفة قبل الحفظ.',
      coursesCount: 1,
      studentsCount: 980,
      trackId: _kMed,
    ),
    Teacher(
      id: 't_med_yousif_saadi',
      name: 'الدكتور يوسف السعدي',
      subject: 'الكيمياء الحيوية',
      bio:
          'متخصص في Biochemistry لطلاب الطب وطب الأسنان. ركّز على '
          'الـ metabolic pathways و clinical correlations.',
      coursesCount: 1,
      studentsCount: 720,
      trackId: _kMed,
    ),
    Teacher(
      id: 't_med_dina_hashimi',
      name: 'الدكتورة دينا الهاشمي',
      subject: 'علم الأدوية',
      bio:
          'أستاذة في كلية الصيدلة، متخصصة في Pharmacology و Toxicology. '
          'تستعمل أمثلة دوائية حقيقية في كل محاضرة.',
      coursesCount: 1,
      studentsCount: 540,
      trackId: _kMed,
    ),
  ];

  static const List<Course> courses = [
    // ─── Preparatory: Math ────────────────────────────────────────────────
    Course(
      id: 'c_calculus',
      title: 'التفاضل والتكامل — السادس العلمي',
      teacherId: 't_ahmed_obeidi',
      teacherName: 'الأستاذ أحمد العبيدي',
      subject: 'الرياضيات',
      lessonsCount: 24,
      isLocked: true,
      trackId: _kPrep,
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
      trackId: _kPrep,
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
      trackId: _kPrep,
      description:
          'يغطي مفاهيم الاحتمال، التوزيعات، الإحصاء الوصفي، ومقاييس '
          'النزعة المركزية والتشتت، مع تطبيقات على بيانات حقيقية.',
    ),
    // ─── Preparatory: Physics ────────────────────────────────────────────
    Course(
      id: 'c_mechanics',
      title: 'الميكانيك الكلاسيكي',
      teacherId: 't_layla_kadhimi',
      teacherName: 'الدكتورة ليلى الكاظمي',
      subject: 'الفيزياء',
      lessonsCount: 20,
      isLocked: true,
      trackId: _kPrep,
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
      trackId: _kPrep,
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
      trackId: _kPrep,
      description:
          'مدخل إلى الحركة الموجية، الموجات الميكانيكية، الموجات الصوتية، '
          'وخصائص الضوء. مع تطبيقات على الظواهر اليومية.',
    ),
    // ─── Preparatory: Biology ────────────────────────────────────────────
    Course(
      id: 'c_cell_biology',
      title: 'علم الخلية والوراثة',
      teacherId: 't_karrar_zubaidi',
      teacherName: 'الدكتور كرار الزبيدي',
      subject: 'علم الأحياء',
      lessonsCount: 19,
      isLocked: true,
      trackId: _kPrep,
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
      trackId: _kPrep,
      description:
          'الجهاز الهضمي، الدوري، التنفسي، البولي، العصبي، والتناسلي. '
          'شرح مفصل بالرسومات مع التركيز على الأسئلة الوزارية المتكررة.',
    ),

    // ─── Engineering ────────────────────────────────────────────────────
    Course(
      id: 'c_eng_math1',
      title: 'الرياضيات الهندسية I — التحليل والمصفوفات',
      teacherId: 't_eng_ali_jubouri',
      teacherName: 'الدكتور علي الجبوري',
      subject: 'الرياضيات الهندسية',
      lessonsCount: 22,
      isLocked: true,
      trackId: _kEng,
      description:
          'يغطي النهايات والاتصال، المشتقات الجزئية، المصفوفات والمحددات، '
          'الفضاءات المتجهة، وتطبيقاتها في المسائل الهندسية.',
    ),
    Course(
      id: 'c_eng_diff_eq',
      title: 'المعادلات التفاضلية للهندسة',
      teacherId: 't_eng_ali_jubouri',
      teacherName: 'الدكتور علي الجبوري',
      subject: 'الرياضيات الهندسية',
      lessonsCount: 16,
      isLocked: true,
      trackId: _kEng,
      description:
          'المعادلات التفاضلية من الدرجة الأولى والثانية، المعادلات '
          'الخطية، تحويل لابلاس، وتطبيقاتها في الدوائر والميكانيك.',
    ),
    Course(
      id: 'c_eng_statics',
      title: 'الستاتيك (الميكانيك الهندسي I)',
      teacherId: 't_eng_zahraa_anbari',
      teacherName: 'الدكتورة زهراء العنبري',
      subject: 'الميكانيك التطبيقي',
      lessonsCount: 18,
      isLocked: false,
      trackId: _kEng,
      description:
          'الاتزان، تحليل الجمالونات (Trusses)، الإطارات، الاحتكاك، '
          'ومركز الكتلة. مع مسائل تطبيقية من امتحانات الهندسة المدنية.',
    ),
    Course(
      id: 'c_eng_circuits',
      title: 'الدوائر الكهربائية I',
      teacherId: 't_eng_omar_najjar',
      teacherName: 'المهندس عمر النجار',
      subject: 'الدوائر الكهربائية',
      lessonsCount: 20,
      isLocked: true,
      trackId: _kEng,
      description:
          'قوانين كيرشوف، تحليل العقد والحلقات، المحولات، الدوائر '
          'الزمنية (RC و RL)، والتيار المتناوب AC.',
    ),
    Course(
      id: 'c_eng_electronics',
      title: 'الإلكترونيات الرقمية الأساسية',
      teacherId: 't_eng_omar_najjar',
      teacherName: 'المهندس عمر النجار',
      subject: 'الدوائر الكهربائية',
      lessonsCount: 14,
      isLocked: true,
      trackId: _kEng,
      description:
          'البوابات المنطقية، المعادلات البولية، خرائط كارنوف، '
          'الـ Flip-Flops، والمسجلات (Registers). شرح مع محاكاة عملية.',
    ),
    Course(
      id: 'c_eng_cpp',
      title: 'مقدمة البرمجة بلغة C++',
      teacherId: 't_eng_yasin_dulaimi',
      teacherName: 'الدكتور ياسين الدليمي',
      subject: 'البرمجة الهندسية',
      lessonsCount: 24,
      isLocked: true,
      trackId: _kEng,
      description:
          'من المتغيرات والشروط حتى المؤشرات، البرمجة الكائنية، '
          'وهياكل البيانات الأساسية. مع تمارين عملية لكل محاضرة.',
    ),

    // ─── Medical ────────────────────────────────────────────────────────
    Course(
      id: 'c_med_anatomy_upper',
      title: 'تشريح الأطراف العلوية (Upper Limb)',
      teacherId: 't_med_hassan_tamimi',
      teacherName: 'الدكتور حسن التميمي',
      subject: 'علم التشريح',
      lessonsCount: 18,
      isLocked: true,
      trackId: _kMed,
      description:
          'العظام، العضلات، الأعصاب، والأوعية الدموية للطرف العلوي. '
          'مدعوم بصور تشريحية ومسائل إكلينيكية.',
    ),
    Course(
      id: 'c_med_anatomy_lower',
      title: 'تشريح الأطراف السفلية (Lower Limb)',
      teacherId: 't_med_hassan_tamimi',
      teacherName: 'الدكتور حسن التميمي',
      subject: 'علم التشريح',
      lessonsCount: 16,
      isLocked: false,
      trackId: _kMed,
      description:
          'تشريح مفصل للحوض، الفخذ، الركبة، الساق، والقدم. مع تطبيقات '
          'سريرية على الإصابات الشائعة.',
    ),
    Course(
      id: 'c_med_physiology',
      title: 'الفسلجة الطبية — الجهاز القلبي الوعائي',
      teacherId: 't_med_rasha_qaisi',
      teacherName: 'الدكتورة رشا القيسي',
      subject: 'الفسلجة الطبية',
      lessonsCount: 20,
      isLocked: true,
      trackId: _kMed,
      description:
          'فسلجة القلب، التحكم العصبي والهرموني، تخطيط القلب الـ ECG، '
          'وضغط الدم. مع ربط الفسلجة بالحالات المرضية الشائعة.',
    ),
    Course(
      id: 'c_med_biochem',
      title: 'الكيمياء الحيوية — أيض الكاربوهيدرات والدهون',
      teacherId: 't_med_yousif_saadi',
      teacherName: 'الدكتور يوسف السعدي',
      subject: 'الكيمياء الحيوية',
      lessonsCount: 17,
      isLocked: true,
      trackId: _kMed,
      description:
          'الـ Glycolysis، دورة كريبس، أيض الدهون، وتنظيم سكر الدم. '
          'مدعوم بتطبيقات إكلينيكية على السكري وأمراض الأيض.',
    ),
    Course(
      id: 'c_med_pharma',
      title: 'علم الأدوية العام',
      teacherId: 't_med_dina_hashimi',
      teacherName: 'الدكتورة دينا الهاشمي',
      subject: 'علم الأدوية',
      lessonsCount: 15,
      isLocked: true,
      trackId: _kMed,
      description:
          'الـ Pharmacokinetics و Pharmacodynamics، الجرعات الدوائية، '
          'التداخلات، والأعراض الجانبية. مع أمثلة لأشهر الأدوية.',
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

    // ─── Engineering lesson plans ──────────────────────────────────────
    'c_eng_math1': [
      Lesson(
        id: 'l1',
        title: 'تقديم الكورس وخطة الفصل',
        durationMinutes: 9,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'النهايات والاتصال', durationMinutes: 28),
      Lesson(id: 'l3', title: 'المشتقات الجزئية', durationMinutes: 26),
      Lesson(id: 'l4', title: 'المصفوفات والمحددات', durationMinutes: 30),
      Lesson(
        id: 'l5',
        title: 'الفضاءات المتجهة والاستقلال الخطي',
        durationMinutes: 24,
      ),
      Lesson(id: 'l6', title: 'مراجعة وحلول مسائل', durationMinutes: 36),
    ],
    'c_eng_diff_eq': [
      Lesson(
        id: 'l1',
        title: 'مقدمة المعادلات التفاضلية',
        durationMinutes: 10,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'معادلات الدرجة الأولى', durationMinutes: 24),
      Lesson(
        id: 'l3',
        title: 'معادلات الدرجة الثانية الخطية',
        durationMinutes: 28,
      ),
      Lesson(id: 'l4', title: 'تحويل لابلاس', durationMinutes: 32),
      Lesson(
        id: 'l5',
        title: 'تطبيقات في الدوائر والميكانيك',
        durationMinutes: 26,
      ),
    ],
    'c_eng_statics': [
      Lesson(
        id: 'l1',
        title: 'مقدمة الستاتيك ومفهوم الاتزان',
        durationMinutes: 11,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'القوى المركبة والمحصلة', durationMinutes: 24),
      Lesson(id: 'l3', title: 'الاتزان في 2D و 3D', durationMinutes: 28),
      Lesson(
        id: 'l4',
        title: 'تحليل الجمالونات (Trusses)',
        durationMinutes: 30,
      ),
      Lesson(id: 'l5', title: 'الاحتكاك ومركز الكتلة', durationMinutes: 26),
    ],
    'c_eng_circuits': [
      Lesson(
        id: 'l1',
        title: 'مقدمة الدوائر — العناصر الأساسية',
        durationMinutes: 10,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'قوانين كيرشوف', durationMinutes: 26),
      Lesson(id: 'l3', title: 'تحليل العقد والحلقات', durationMinutes: 30),
      Lesson(id: 'l4', title: 'الدوائر الزمنية RC و RL', durationMinutes: 28),
      Lesson(id: 'l5', title: 'التيار المتناوب AC', durationMinutes: 32),
      Lesson(id: 'l6', title: 'مراجعة وزاريات هندسة', durationMinutes: 38),
    ],
    'c_eng_electronics': [
      Lesson(
        id: 'l1',
        title: 'مقدمة الإلكترونيات الرقمية',
        durationMinutes: 9,
        isFreePreview: true,
      ),
      Lesson(
        id: 'l2',
        title: 'البوابات المنطقية الأساسية',
        durationMinutes: 24,
      ),
      Lesson(
        id: 'l3',
        title: 'الجبر البولي وخرائط كارنوف',
        durationMinutes: 28,
      ),
      Lesson(id: 'l4', title: 'الـ Flip-Flops والمسجلات', durationMinutes: 26),
    ],
    'c_eng_cpp': [
      Lesson(
        id: 'l1',
        title: 'مقدمة الكورس — Hello, C++',
        durationMinutes: 8,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'المتغيرات والشروط', durationMinutes: 22),
      Lesson(id: 'l3', title: 'الحلقات والدوال', durationMinutes: 24),
      Lesson(id: 'l4', title: 'المؤشرات والمصفوفات', durationMinutes: 28),
      Lesson(id: 'l5', title: 'البرمجة الكائنية OOP', durationMinutes: 30),
      Lesson(id: 'l6', title: 'هياكل البيانات الأساسية', durationMinutes: 26),
    ],

    // ─── Medical lesson plans ──────────────────────────────────────────
    'c_med_anatomy_upper': [
      Lesson(
        id: 'l1',
        title: 'مقدمة تشريح الطرف العلوي',
        durationMinutes: 10,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'عظام وعضلات الكتف', durationMinutes: 28),
      Lesson(id: 'l3', title: 'العضد والساعد', durationMinutes: 26),
      Lesson(id: 'l4', title: 'أعصاب الضفيرة العضدية', durationMinutes: 30),
      Lesson(id: 'l5', title: 'تشريح اليد والأصابع', durationMinutes: 24),
      Lesson(id: 'l6', title: 'مراجعة بصور إكلينيكية', durationMinutes: 35),
    ],
    'c_med_anatomy_lower': [
      Lesson(
        id: 'l1',
        title: 'مقدمة الطرف السفلي',
        durationMinutes: 9,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'الحوض والفخذ', durationMinutes: 26),
      Lesson(id: 'l3', title: 'الركبة والساق', durationMinutes: 28),
      Lesson(id: 'l4', title: 'القدم والأقواس', durationMinutes: 22),
    ],
    'c_med_physiology': [
      Lesson(
        id: 'l1',
        title: 'مقدمة فسلجة القلب',
        durationMinutes: 11,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'دورة القلب والـ ECG', durationMinutes: 28),
      Lesson(id: 'l3', title: 'النظم القلبي', durationMinutes: 24),
      Lesson(id: 'l4', title: 'تنظيم ضغط الدم', durationMinutes: 26),
      Lesson(
        id: 'l5',
        title: 'فشل القلب — تطبيقات سريرية',
        durationMinutes: 30,
      ),
    ],
    'c_med_biochem': [
      Lesson(
        id: 'l1',
        title: 'مقدمة الكيمياء الحيوية',
        durationMinutes: 10,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'تحلل السكر Glycolysis', durationMinutes: 26),
      Lesson(id: 'l3', title: 'دورة كريبس', durationMinutes: 24),
      Lesson(id: 'l4', title: 'أيض الدهون', durationMinutes: 28),
      Lesson(id: 'l5', title: 'تنظيم سكر الدم والسكري', durationMinutes: 24),
    ],
    'c_med_pharma': [
      Lesson(
        id: 'l1',
        title: 'مقدمة علم الأدوية',
        durationMinutes: 9,
        isFreePreview: true,
      ),
      Lesson(id: 'l2', title: 'الـ Pharmacokinetics', durationMinutes: 26),
      Lesson(id: 'l3', title: 'الـ Pharmacodynamics', durationMinutes: 24),
      Lesson(
        id: 'l4',
        title: 'التداخلات والآثار الجانبية',
        durationMinutes: 22,
      ),
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
          kind: AttachmentKind.pdf,
          sizeBytes: 1_400 * 1024,
        ),
    ];
  }
}
