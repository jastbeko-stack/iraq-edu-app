import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../admin/data/catalog_store.dart';
import '../domain/coupon.dart';
import '../domain/coupon_codes.dart';

/// SharedPreferences key for the JSON-encoded list of unlocked course ids.
const _kUnlockedCoursesKey = 'unlocked_courses_v1';

/// Repository that persists the set of courses the current user has unlocked.
///
/// Coupon *lookup* is delegated to [CourseCouponsNotifier] (admin-mutable);
/// this repo only owns the `unlocked` set persistence.
class CouponRepository {
  CouponRepository(this._prefs);

  final SharedPreferences _prefs;

  Set<String> loadUnlockedCourseIds() {
    final raw = _prefs.getStringList(_kUnlockedCoursesKey);
    return raw == null ? <String>{} : raw.toSet();
  }

  Future<void> _save(Set<String> unlocked) =>
      _prefs.setStringList(_kUnlockedCoursesKey, unlocked.toList());

  /// Apply a known [coupon] to the unlocked set. Returns one of the three
  /// [CouponRedemptionResult] variants depending on whether anything was
  /// newly granted.
  Future<CouponRedemptionResult> apply(Coupon coupon) async {
    final current = loadUnlockedCourseIds();
    final newlyUnlocked = coupon.courseIds
        .where((id) => !current.contains(id))
        .toList();

    if (newlyUnlocked.isEmpty) {
      return CouponRedemptionAlreadyOwned(coupon: coupon);
    }

    final updated = {...current, ...coupon.courseIds};
    await _save(updated);
    return CouponRedemptionSuccess(
      coupon: coupon,
      newlyUnlocked: newlyUnlocked,
    );
  }

  /// Wipe all unlocks. Exposed only so the demo Profile screen can reset
  /// state between manual test runs.
  Future<void> resetAll() => _save(<String>{});

  /// Convenience entry-point used by tests and offline tools: looks up
  /// [code] against the *seed* coupon list and applies it. Production code
  /// should go through [UnlockedCoursesNotifier.redeem] which also accounts
  /// for admin-generated coupons.
  Future<CouponRedemptionResult> redeem(String code) async {
    final coupon = CouponCodes.lookup(code);
    if (coupon == null) return const CouponRedemptionInvalid();
    return apply(coupon);
  }
}

/// Provider for the [SharedPreferences] singleton.
///
/// Must be overridden in `main()` with the resolved instance before
/// `runApp` so synchronous access from downstream providers always works.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() with the '
    'resolved SharedPreferences instance.',
  );
});

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return CouponRepository(ref.watch(sharedPreferencesProvider));
});

class UnlockedCoursesNotifier extends StateNotifier<Set<String>> {
  UnlockedCoursesNotifier(this._ref, this._repository)
    : super(_repository.loadUnlockedCourseIds());

  final Ref _ref;
  final CouponRepository _repository;

  void refresh() => state = _repository.loadUnlockedCourseIds();

  Future<CouponRedemptionResult> redeem(String code) async {
    final coupon = _ref.read(courseCouponsProvider.notifier).lookup(code);
    if (coupon == null) return const CouponRedemptionInvalid();

    final result = await _repository.apply(coupon);
    if (result is CouponRedemptionSuccess) refresh();
    return result;
  }

  Future<void> resetAll() async {
    await _repository.resetAll();
    refresh();
  }
}

final unlockedCoursesProvider =
    StateNotifierProvider<UnlockedCoursesNotifier, Set<String>>((ref) {
      final repo = ref.watch(couponRepositoryProvider);
      return UnlockedCoursesNotifier(ref, repo);
    });

/// Convenience: is this specific course unlocked?
final isCourseUnlockedProvider = Provider.family<bool, String>((ref, courseId) {
  return ref.watch(unlockedCoursesProvider).contains(courseId);
});
