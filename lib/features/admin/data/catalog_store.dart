import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/models/course.dart';
import '../../../shared/models/sample_data.dart';
import '../../../shared/models/teacher.dart';
import '../../coupons/data/coupon_repository.dart';
import '../../coupons/domain/coupon.dart';
import '../../coupons/domain/coupon_codes.dart';
import '../../study_guides/data/pdf_manifest.dart';
import '../../study_guides/data/study_guides_sample_data.dart';
import '../../study_guides/domain/study_guide.dart';
import '../../study_guides/domain/study_guide_codes.dart';

/// Mutable, JSON-persisted catalog of teachers, courses, study guides, and
/// admin-generated coupons.
///
/// The seed data still lives under [SampleData] / [StudyGuidesData] /
/// [CouponCodes] / [StudyGuideCodes] — on first launch each list is hydrated
/// from the seed and saved to [SharedPreferences]. After that the prefs copy
/// is the source of truth so admin edits survive a refresh.
///
/// The student-facing UI never touches these notifiers directly — it goes
/// through `*ForTrackProvider` / `couponLookupProvider` etc., so swapping
/// this whole layer for Firestore later means changing only this file.
const _kTeachersKey = 'admin_catalog_teachers_v1';
const _kCoursesKey = 'admin_catalog_courses_v1';
const _kGuidesKey = 'admin_catalog_guides_v1';
const _kCourseCouponsKey = 'admin_catalog_course_coupons_v1';
const _kGuideCouponsKey = 'admin_catalog_guide_coupons_v1';

class _PersistedListNotifier<T> extends StateNotifier<List<T>> {
  _PersistedListNotifier({
    required SharedPreferences prefs,
    required String storageKey,
    required List<T> seed,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
  }) : _prefs = prefs,
       _storageKey = storageKey,
       _toJson = toJson,
       super(_load(prefs, storageKey, seed, fromJson));

  final SharedPreferences _prefs;
  final String _storageKey;
  final Map<String, dynamic> Function(T) _toJson;

  static List<T> _load<T>(
    SharedPreferences prefs,
    String key,
    List<T> seed,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return List<T>.from(seed);
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .cast<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: true);
    } catch (_) {
      // Corrupt data — fall back to the seed and rewrite.
      return List<T>.from(seed);
    }
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(state.map(_toJson).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  Future<void> add(T item) async {
    state = [...state, item];
    await _persist();
  }

  Future<void> update(bool Function(T) match, T replacement) async {
    state = [
      for (final item in state)
        if (match(item)) replacement else item,
    ];
    await _persist();
  }

  Future<void> remove(bool Function(T) match) async {
    state = state.where((e) => !match(e)).toList(growable: true);
    await _persist();
  }

  Future<void> resetToSeed(List<T> seed) async {
    state = List<T>.from(seed);
    await _persist();
  }
}

class TeachersNotifier extends _PersistedListNotifier<Teacher> {
  TeachersNotifier(SharedPreferences prefs)
    : super(
        prefs: prefs,
        storageKey: _kTeachersKey,
        seed: SampleData.teachers,
        toJson: (t) => t.toJson(),
        fromJson: Teacher.fromJson,
      );

  Future<void> upsert(Teacher t) async {
    final exists = state.any((e) => e.id == t.id);
    if (exists) {
      await update((e) => e.id == t.id, t);
    } else {
      await add(t);
    }
  }

  Future<void> deleteById(String id) async => remove((e) => e.id == id);

  Future<void> resetToDefaults() async => resetToSeed(SampleData.teachers);
}

class CoursesNotifier extends _PersistedListNotifier<Course> {
  CoursesNotifier(SharedPreferences prefs)
    : super(
        prefs: prefs,
        storageKey: _kCoursesKey,
        seed: SampleData.courses,
        toJson: (c) => c.toJson(),
        fromJson: Course.fromJson,
      );

  Future<void> upsert(Course c) async {
    final exists = state.any((e) => e.id == c.id);
    if (exists) {
      await update((e) => e.id == c.id, c);
    } else {
      await add(c);
    }
  }

  Future<void> deleteById(String id) async => remove((e) => e.id == id);

  Future<void> resetToDefaults() async => resetToSeed(SampleData.courses);
}

class StudyGuidesNotifier extends _PersistedListNotifier<StudyGuide> {
  StudyGuidesNotifier(SharedPreferences prefs)
    : super(
        prefs: prefs,
        storageKey: _kGuidesKey,
        seed: StudyGuidesData.guides,
        toJson: (g) => g.toJson(),
        fromJson: StudyGuide.fromJson,
      );

  Future<void> upsert(StudyGuide g) async {
    final exists = state.any((e) => e.id == g.id);
    if (exists) {
      await update((e) => e.id == g.id, g);
    } else {
      await add(g);
    }
  }

  Future<void> deleteById(String id) async => remove((e) => e.id == id);

  Future<void> resetToDefaults() async => resetToSeed(StudyGuidesData.guides);
}

class CourseCouponsNotifier extends _PersistedListNotifier<Coupon> {
  CourseCouponsNotifier(SharedPreferences prefs)
    : super(
        prefs: prefs,
        storageKey: _kCourseCouponsKey,
        seed: CouponCodes.validCoupons,
        toJson: (c) => c.toJson(),
        fromJson: Coupon.fromJson,
      );

  Future<void> upsert(Coupon c) async {
    final exists = state.any(
      (e) => e.code.toUpperCase() == c.code.toUpperCase(),
    );
    if (exists) {
      await update((e) => e.code.toUpperCase() == c.code.toUpperCase(), c);
    } else {
      await add(c);
    }
  }

  Future<void> deleteByCode(String code) async =>
      remove((e) => e.code.toUpperCase() == code.toUpperCase());

  Future<void> resetToDefaults() async => resetToSeed(CouponCodes.validCoupons);

  Coupon? lookup(String code) {
    final normalized = code.trim().toUpperCase();
    for (final c in state) {
      if (c.code.toUpperCase() == normalized) return c;
    }
    return null;
  }
}

class GuideCouponsNotifier extends _PersistedListNotifier<StudyGuideCoupon> {
  GuideCouponsNotifier(SharedPreferences prefs)
    : super(
        prefs: prefs,
        storageKey: _kGuideCouponsKey,
        seed: StudyGuideCodes.validCoupons,
        toJson: (c) => c.toJson(),
        fromJson: StudyGuideCoupon.fromJson,
      );

  Future<void> upsert(StudyGuideCoupon c) async {
    final exists = state.any(
      (e) => e.code.toUpperCase() == c.code.toUpperCase(),
    );
    if (exists) {
      await update((e) => e.code.toUpperCase() == c.code.toUpperCase(), c);
    } else {
      await add(c);
    }
  }

  Future<void> deleteByCode(String code) async =>
      remove((e) => e.code.toUpperCase() == code.toUpperCase());

  Future<void> resetToDefaults() async =>
      resetToSeed(StudyGuideCodes.validCoupons);

  StudyGuideCoupon? lookup(String code) {
    final normalized = code.trim().toUpperCase();
    for (final c in state) {
      if (c.code.toUpperCase() == normalized) return c;
    }
    return null;
  }
}

// ─── Riverpod providers ──────────────────────────────────────────────────

final teachersProvider = StateNotifierProvider<TeachersNotifier, List<Teacher>>(
  (ref) => TeachersNotifier(ref.watch(sharedPreferencesProvider)),
);

final coursesProvider = StateNotifierProvider<CoursesNotifier, List<Course>>(
  (ref) => CoursesNotifier(ref.watch(sharedPreferencesProvider)),
);

final studyGuidesProvider =
    StateNotifierProvider<StudyGuidesNotifier, List<StudyGuide>>(
      (ref) => StudyGuidesNotifier(ref.watch(sharedPreferencesProvider)),
    );

final courseCouponsProvider =
    StateNotifierProvider<CourseCouponsNotifier, List<Coupon>>(
      (ref) => CourseCouponsNotifier(ref.watch(sharedPreferencesProvider)),
    );

final guideCouponsProvider =
    StateNotifierProvider<GuideCouponsNotifier, List<StudyGuideCoupon>>(
      (ref) => GuideCouponsNotifier(ref.watch(sharedPreferencesProvider)),
    );

// ─── Lookup helpers (read-only) ──────────────────────────────────────────

final teacherByIdProvider = Provider.family<Teacher?, String>((ref, id) {
  final teachers = ref.watch(teachersProvider);
  for (final t in teachers) {
    if (t.id == id) return t;
  }
  return null;
});

final courseByIdProvider = Provider.family<Course?, String>((ref, id) {
  final courses = ref.watch(coursesProvider);
  for (final c in courses) {
    if (c.id == id) return c;
  }
  return null;
});

final studyGuideByIdProvider = Provider.family<StudyGuide?, String>((ref, id) {
  final guides = ref.watch(studyGuidesProvider);
  for (final g in guides) {
    if (g.id == id) return g;
  }
  // Fall back to bundled manifest entries so guides added via
  // assets/pdfs/manifest.json resolve from detail screens / deep links.
  final manifest = ref.watch(manifestStudyGuidesProvider);
  for (final g in manifest) {
    if (g.id == id) return g;
  }
  return null;
});

final coursesByTeacherProvider = Provider.family<List<Course>, String>(
  (ref, teacherId) => ref
      .watch(coursesProvider)
      .where((c) => c.teacherId == teacherId)
      .toList(),
);
