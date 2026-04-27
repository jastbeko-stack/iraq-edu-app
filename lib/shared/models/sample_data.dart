import 'course.dart';
import 'teacher.dart';

/// In-memory sample data used by stub screens.
///
/// Replace these lookups with Firestore queries (or a Riverpod repository)
/// once the backend collections are populated.
abstract final class SampleData {
  static const List<Teacher> teachers = [
    Teacher(
      id: 't_ahmed',
      name: 'الأستاذ أحمد العبيدي',
      subject: 'الرياضيات',
      bio:
          'مدرس رياضيات للسادس العلمي بخبرة تزيد عن 12 سنة. أسلوب بسيط ومباشر '
          'يركز على فهم الأساسيات وحل الأسئلة الوزارية.',
      coursesCount: 4,
      studentsCount: 1820,
    ),
    Teacher(
      id: 't_layla',
      name: 'الدكتورة ليلى الكاظمي',
      subject: 'الفيزياء',
      bio:
          'دكتوراه في الفيزياء النظرية. تشرح الفيزياء بطريقة قصصية ومبسطة '
          'مع أمثلة من الحياة اليومية.',
      coursesCount: 3,
      studentsCount: 1340,
    ),
    Teacher(
      id: 't_omar',
      name: 'الأستاذ عمر الجبوري',
      subject: 'الكيمياء',
      bio:
          'متخصص في كيمياء السادس العلمي مع تركيز على الأسئلة الوزارية '
          'وأسئلة المراجعة المركزة.',
      coursesCount: 2,
      studentsCount: 980,
    ),
  ];

  static const List<Course> courses = [
    Course(
      id: 'c_math_calc',
      title: 'التفاضل والتكامل — السادس العلمي',
      teacherId: 't_ahmed',
      teacherName: 'الأستاذ أحمد العبيدي',
      subject: 'الرياضيات',
      lessonsCount: 24,
      isLocked: true,
      description:
          'كورس شامل يغطي الفصل الأول والثاني من منهج التفاضل والتكامل '
          'مع حلول الأسئلة الوزارية للسنوات الخمس الأخيرة.',
    ),
    Course(
      id: 'c_physics_mech',
      title: 'الميكانيك الكلاسيكي',
      teacherId: 't_layla',
      teacherName: 'الدكتورة ليلى الكاظمي',
      subject: 'الفيزياء',
      lessonsCount: 18,
      isLocked: true,
      description:
          'يغطي قوانين نيوتن، الشغل والطاقة، الزخم، والحركة الدورانية مع '
          'تطبيقات وأمثلة محلولة.',
    ),
    Course(
      id: 'c_chem_organic',
      title: 'الكيمياء العضوية',
      teacherId: 't_omar',
      teacherName: 'الأستاذ عمر الجبوري',
      subject: 'الكيمياء',
      lessonsCount: 16,
      isLocked: false,
      description:
          'مقدمة في الكيمياء العضوية، أنواع المركبات، التفاعلات الأساسية، '
          'وحل أسئلة الكتاب المدرسي.',
    ),
  ];

  static const List<Lesson> sampleLessons = [
    Lesson(
      id: 'l1',
      title: 'مقدمة الكورس',
      durationMinutes: 8,
      isFreePreview: true,
    ),
    Lesson(id: 'l2', title: 'الفصل الأول — الأساسيات', durationMinutes: 22),
    Lesson(id: 'l3', title: 'الفصل الأول — أمثلة محلولة', durationMinutes: 28),
    Lesson(id: 'l4', title: 'الفصل الثاني — المفاهيم', durationMinutes: 25),
    Lesson(id: 'l5', title: 'مراجعة الأسئلة الوزارية', durationMinutes: 35),
  ];

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
}
