import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iraq_edu_app/features/auth/data/auth_controller.dart';
import 'package:iraq_edu_app/features/coupons/data/coupon_repository.dart';
import 'package:iraq_edu_app/features/coupons/domain/coupon.dart';
import 'package:iraq_edu_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test override that hands the providers an [AuthController] which
/// stays signed-out and never subscribes to Supabase — avoids the
/// session-refresh timer that would otherwise outlive the widget tree.
final _authOverride = authControllerProvider
    .overrideWith((ref) => AuthController.signedOutForTest());

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('App boots and renders the home screen with Arabic title', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          _authOverride,
        ],
        child: const IraqEduApp(),
      ),
    );
    await tester.pump();

    expect(find.text('منصة المهندس التعليمية'), findsWidgets);
  });

  testWidgets('App enforces RTL directionality', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          _authOverride,
        ],
        child: const IraqEduApp(),
      ),
    );
    await tester.pump();

    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });

  group('CouponRepository', () {
    late SharedPreferences prefs;
    late CouponRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      repo = CouponRepository(prefs);
    });

    test('rejects an invalid code', () async {
      final result = await repo.redeem('NOT-A-CODE');
      expect(result, isA<CouponRedemptionInvalid>());
      expect(repo.loadUnlockedCourseIds(), isEmpty);
    });

    test('redeems a valid code and persists unlocked course ids', () async {
      final result = await repo.redeem('CALC2025');
      expect(result, isA<CouponRedemptionSuccess>());
      final success = result as CouponRedemptionSuccess;
      expect(success.newlyUnlocked, contains('c_calculus'));
      expect(repo.loadUnlockedCourseIds(), contains('c_calculus'));
    });

    test('reports already-owned on second redemption', () async {
      await repo.redeem('CALC2025');
      final result = await repo.redeem('CALC2025');
      expect(result, isA<CouponRedemptionAlreadyOwned>());
    });

    test('master code unlocks all courses', () async {
      final result = await repo.redeem('all2025'); // case-insensitive
      expect(result, isA<CouponRedemptionSuccess>());
      expect(repo.loadUnlockedCourseIds().length, greaterThanOrEqualTo(8));
    });

    test('resetAll clears unlocks', () async {
      await repo.redeem('ALL2025');
      await repo.resetAll();
      expect(repo.loadUnlockedCourseIds(), isEmpty);
    });
  });
}
