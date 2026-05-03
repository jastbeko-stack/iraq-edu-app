// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'منصة المهندس التعليمية';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCourses => 'الكورسات';

  @override
  String get navTeachers => 'المدرسون';

  @override
  String get navProfile => 'حسابي';

  @override
  String get homeWelcome => 'أهلاً بك';

  @override
  String get homeSubtitle => 'السادس العلمي — منصتك التعليمية';

  @override
  String get homeFeaturedTeachers => 'المدرسون المميزون';

  @override
  String get homeFeaturedCourses => 'الكورسات المميزة';

  @override
  String get homeViewAll => 'عرض الكل';

  @override
  String get teacherProfileTitle => 'صفحة المدرس';

  @override
  String teacherCoursesCount(int count) {
    return '$count كورس';
  }

  @override
  String teacherStudentsCount(int count) {
    return '$count طالب';
  }

  @override
  String get teacherAbout => 'نبذة عن المدرس';

  @override
  String get teacherCourses => 'كورسات المدرس';

  @override
  String get courseDetailsTitle => 'تفاصيل الكورس';

  @override
  String get courseLessons => 'الدروس';

  @override
  String get courseAbout => 'عن الكورس';

  @override
  String get courseEnroll => 'اشتراك بالكورس';

  @override
  String get courseRedeemCoupon => 'استخدام كوبون';

  @override
  String get courseLockedHint =>
      'هذا الكورس مقفل، يرجى الاشتراك أو استخدام كوبون لفتحه';

  @override
  String get profileTitle => 'حسابي';

  @override
  String get profilePhone => 'رقم الهاتف';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileAbout => 'عن التطبيق';

  @override
  String get profileSupport => 'الدعم الفني';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileNotSignedIn => 'لم تقم بتسجيل الدخول بعد';

  @override
  String get profileSignIn => 'تسجيل الدخول';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonLoading => 'جاري التحميل…';

  @override
  String get commonComingSoon => 'قريباً';
}
