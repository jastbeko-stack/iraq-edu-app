import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../admin/data/catalog_store.dart';
import '../../coupons/data/coupon_repository.dart'
    show sharedPreferencesProvider;
import '../domain/study_guide.dart';

/// SharedPreferences key for the JSON-encoded list of unlocked study-guide
/// ids. Intentionally separate from `unlocked_courses_v1` so the two
/// stores never bleed into each other.
const _kUnlockedGuidesKey = 'unlocked_guides_v1';

class StudyGuideCouponRepository {
  StudyGuideCouponRepository(this._prefs);

  final SharedPreferences _prefs;

  Set<String> loadUnlockedGuideIds() {
    final raw = _prefs.getStringList(_kUnlockedGuidesKey);
    return raw == null ? <String>{} : raw.toSet();
  }

  Future<void> _save(Set<String> unlocked) =>
      _prefs.setStringList(_kUnlockedGuidesKey, unlocked.toList());

  Future<StudyGuideRedemptionResult> apply(StudyGuideCoupon coupon) async {
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
  UnlockedGuidesNotifier(this._ref, this._repository)
    : super(_repository.loadUnlockedGuideIds());

  final Ref _ref;
  final StudyGuideCouponRepository _repository;

  void refresh() => state = _repository.loadUnlockedGuideIds();

  Future<StudyGuideRedemptionResult> redeem(String code) async {
    final coupon = _ref.read(guideCouponsProvider.notifier).lookup(code);
    if (coupon == null) return const StudyGuideRedemptionInvalid();
    final result = await _repository.apply(coupon);
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
      return UnlockedGuidesNotifier(ref, repo);
    });

final isGuideUnlockedProvider = Provider.family<bool, String>((ref, guideId) {
  return ref.watch(unlockedGuidesProvider).contains(guideId);
});
