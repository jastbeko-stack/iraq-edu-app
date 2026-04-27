import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// Application title shown in launcher / app bar
  ///
  /// In ar, this message translates to:
  /// **'منصة العراق التعليمية'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navCourses.
  ///
  /// In ar, this message translates to:
  /// **'الكورسات'**
  String get navCourses;

  /// No description provided for @navTeachers.
  ///
  /// In ar, this message translates to:
  /// **'المدرسون'**
  String get navTeachers;

  /// No description provided for @navProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navProfile;

  /// No description provided for @homeWelcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك'**
  String get homeWelcome;

  /// No description provided for @homeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'السادس العلمي — منصتك التعليمية'**
  String get homeSubtitle;

  /// No description provided for @homeFeaturedTeachers.
  ///
  /// In ar, this message translates to:
  /// **'المدرسون المميزون'**
  String get homeFeaturedTeachers;

  /// No description provided for @homeFeaturedCourses.
  ///
  /// In ar, this message translates to:
  /// **'الكورسات المميزة'**
  String get homeFeaturedCourses;

  /// No description provided for @homeViewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get homeViewAll;

  /// No description provided for @teacherProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'صفحة المدرس'**
  String get teacherProfileTitle;

  /// No description provided for @teacherCoursesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} كورس'**
  String teacherCoursesCount(int count);

  /// No description provided for @teacherStudentsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} طالب'**
  String teacherStudentsCount(int count);

  /// No description provided for @teacherAbout.
  ///
  /// In ar, this message translates to:
  /// **'نبذة عن المدرس'**
  String get teacherAbout;

  /// No description provided for @teacherCourses.
  ///
  /// In ar, this message translates to:
  /// **'كورسات المدرس'**
  String get teacherCourses;

  /// No description provided for @courseDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الكورس'**
  String get courseDetailsTitle;

  /// No description provided for @courseLessons.
  ///
  /// In ar, this message translates to:
  /// **'الدروس'**
  String get courseLessons;

  /// No description provided for @courseAbout.
  ///
  /// In ar, this message translates to:
  /// **'عن الكورس'**
  String get courseAbout;

  /// No description provided for @courseEnroll.
  ///
  /// In ar, this message translates to:
  /// **'اشتراك بالكورس'**
  String get courseEnroll;

  /// No description provided for @courseRedeemCoupon.
  ///
  /// In ar, this message translates to:
  /// **'استخدام كوبون'**
  String get courseRedeemCoupon;

  /// No description provided for @courseLockedHint.
  ///
  /// In ar, this message translates to:
  /// **'هذا الكورس مقفل، يرجى الاشتراك أو استخدام كوبون لفتحه'**
  String get courseLockedHint;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get profileTitle;

  /// No description provided for @profilePhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get profilePhone;

  /// No description provided for @profileLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get profileLanguage;

  /// No description provided for @profileAbout.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get profileAbout;

  /// No description provided for @profileSupport.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني'**
  String get profileSupport;

  /// No description provided for @profileLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get profileLogout;

  /// No description provided for @profileNotSignedIn.
  ///
  /// In ar, this message translates to:
  /// **'لم تقم بتسجيل الدخول بعد'**
  String get profileNotSignedIn;

  /// No description provided for @profileSignIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get profileSignIn;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل…'**
  String get commonLoading;

  /// No description provided for @commonComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get commonComingSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
