import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../coupons/data/coupon_repository.dart'
    show sharedPreferencesProvider;
import '../domain/study_guide.dart';
import '../domain/study_guide_codes.dart';

/// SharedPreferences key for the JSON-encoded list of unlocked study-guide
/// ids. Intentionally separate from `unlocked_courses_v1` so the two
/// stores never bleed into each other.
const _kUnlockedGuidesKey = 'unlocked_guides_v1';

/// Local-only persistence of which study guides the current user has
/// unlocked. Same shape as [CouponRepository] but for the guides store —
/// kept parallel rather than generic so each store can evolve
/// independently (e.g. guides may add a "preview pages" entitlement).
class StudyGuideCouponRepository {
  StudyGuideCouponRepository(this._prefs);

  final SharedPreferences _prefs;

  Set<String> loadUnlockedGuideIds() {
    final raw = _prefs.getStringList(_kUnlockedGuidesKey);
    return raw == null ? <String>{} : raw.toSet();
  }

  Future<void> _save(Set<String> unlocked) =>
      _prefs.setStringList(_kUnlockedGuidesKey, unlocked.toList());

  Future<StudyGuideRedemptionResult> redeem(String code) async {
    final coupon = StudyGuideCodes.lookup(code);
    if (coupon == null) return const StudyGuideRedemptionInvalid();

    final current = loadUnlockedGuideIds();
    final newlyUnlocked = coupon.guideIds
        .where((id) => !current.contains(id))
        .toList();

    if (newlyUnlocked.isEmpty) {
      return StudyGuideRedemptionAlreadyOwned(coupon: coupon);
    }

    final updated = {...current, ...coupon.guideIds};
    await _save(updated);
    return StudyGuideRedemptionSuccess(
      coupon: coupon,
      newlyUnlocked: newlyUnlocked,
    );
  }

  Future<void> resetAll() => _save(<String>{});
}

final studyGuideCouponRepositoryProvider = Provider<StudyGuideCouponRepository>(
  (ref) => StudyGuideCouponRepository(ref.watch(sharedPreferencesProvider)),
);

class UnlockedGuidesNotifier extends StateNotifier<Set<String>> {
  UnlockedGuidesNotifier(this._repository)
    : super(_repository.loadUnlockedGuideIds());

  final StudyGuideCouponRepository _repository;

  void refresh() => state = _repository.loadUnlockedGuideIds();

  Future<StudyGuideRedemptionResult> redeem(String code) async {
    final result = await _repository.redeem(code);
    if (result is StudyGuideRedemptionSuccess) refresh();
    return result;
  }

  Future<void> resetAll() async {
    await _repository.resetAll();
    refresh();
  }
}

final unlockedGuidesProvider =
    StateNotifierProvider<UnlockedGuidesNotifier, Set<String>>((ref) {
      final repo = ref.watch(studyGuideCouponRepositoryProvider);
      return UnlockedGuidesNotifier(repo);
    });

final isGuideUnlockedProvider = Provider.family<bool, String>((ref, guideId) {
  return ref.watch(unlockedGuidesProvider).contains(guideId);
});
