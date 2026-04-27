import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/coupon.dart';
import '../domain/coupon_codes.dart';

/// SharedPreferences key for the JSON-encoded list of unlocked course ids.
const _kUnlockedCoursesKey = 'unlocked_courses_v1';

/// Repository that persists the set of courses the current user has unlocked.
///
/// This is a *local-only* implementation for the no-backend phase. When
/// Cloud Functions are added the implementation should be swapped out for
/// one that calls a `redeemCoupon` callable function and reads entitlements
/// from Firestore — the rest of the app keeps consuming
/// [unlockedCoursesProvider] without changes.
class CouponRepository {
  CouponRepository(this._prefs);

  final SharedPreferences _prefs;

  Set<String> loadUnlockedCourseIds() {
    final raw = _prefs.getStringList(_kUnlockedCoursesKey);
    return raw == null ? <String>{} : raw.toSet();
  }

  Future<void> _save(Set<String> unlocked) =>
      _prefs.setStringList(_kUnlockedCoursesKey, unlocked.toList());

  /// Attempt to redeem [code]. Mirrors the eventual Cloud Function contract:
  /// invalid → [CouponRedemptionInvalid], already-owned →
  /// [CouponRedemptionAlreadyOwned], success → [CouponRedemptionSuccess]
  /// with the list of newly unlocked courses.
  Future<CouponRedemptionResult> redeem(String code) async {
    final coupon = CouponCodes.lookup(code);
    if (coupon == null) return const CouponRedemptionInvalid();

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
}

/// Provider for the [SharedPreferences] singleton.
///
/// Must be overridden in `main()` with the resolved instance before
/// `runApp` so synchronous access from downstream providers always works:
///
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// runApp(ProviderScope(
///   overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
///   child: const IraqEduApp(),
/// ));
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() with the '
    'resolved SharedPreferences instance.',
  );
});

/// Provides the [CouponRepository] backed by the resolved prefs instance.
final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return CouponRepository(ref.watch(sharedPreferencesProvider));
});

/// Reactive set of unlocked course ids. Reads from the repository on first
/// build and refreshes on demand via [UnlockedCoursesNotifier.refresh].
class UnlockedCoursesNotifier extends StateNotifier<Set<String>> {
  UnlockedCoursesNotifier(this._repository)
    : super(_repository.loadUnlockedCourseIds());

  final CouponRepository _repository;

  void refresh() => state = _repository.loadUnlockedCourseIds();

  Future<CouponRedemptionResult> redeem(String code) async {
    final result = await _repository.redeem(code);
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
      return UnlockedCoursesNotifier(repo);
    });

/// Convenience: is this specific course unlocked?
final isCourseUnlockedProvider = Provider.family<bool, String>((ref, courseId) {
  return ref.watch(unlockedCoursesProvider).contains(courseId);
});
