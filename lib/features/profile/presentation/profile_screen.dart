import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../auth/data/auth_controller.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/login_screen.dart';
import '../../coupons/data/coupon_repository.dart';
import '../../coupons/presentation/coupon_redemption_sheet.dart';
import '../../study_guides/data/study_guide_repository.dart';
import '../../study_guides/presentation/widgets/study_guide_coupon_sheet.dart';

/// Profile / settings screen.
///
/// Shows the auth state at the top (signed-out → "تسجيل الدخول" CTA;
/// signed-in → phone number + sign-out), followed by entitlements
/// (unlocked courses + unlocked guides + redeem shortcuts) and settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final unlockedCourses = ref.watch(unlockedCoursesProvider).length;
    final unlockedGuides = ref.watch(unlockedGuidesProvider).length;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AuthHeader(state: authState),
          const SizedBox(height: 12),
          if (authState is AuthSignedIn)
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل الخروج'),
            )
          else
            FilledButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
              icon: const Icon(Icons.login),
              label: const Text('تسجيل الدخول'),
            ),
          const SizedBox(height: 24),
          const _SectionLabel(text: 'كورساتي'),
          const SizedBox(height: 8),
          _CountTile(
            icon: Icons.lock_open,
            title: 'الكورسات المفتوحة',
            count: unlockedCourses,
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.confirmation_number_outlined),
              title: const Text('تفعيل كوبون كورس'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => CouponRedemptionSheet.show(context),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel(text: 'ملازمي'),
          const SizedBox(height: 8),
          _CountTile(
            icon: Icons.collections_bookmark,
            title: 'الملازم المفعّلة',
            count: unlockedGuides,
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('تفعيل كوبون ملزمة'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => StudyGuideCouponSheet.show(context),
            ),
          ),
          if (unlockedCourses > 0 || unlockedGuides > 0) ...[
            const SizedBox(height: 8),
            Card(
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(
                  Icons.refresh,
                  color: theme.colorScheme.onErrorContainer,
                ),
                title: Text(
                  'إعادة تعيين المفعّل (تجريبي)',
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'يمسح كل الكورسات والملازم التي فتحتها بالكوبونات',
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                onTap: () => _confirmReset(context, ref),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const _SectionLabel(text: 'الإعدادات'),
          const SizedBox(height: 8),
          const _SettingsTile(
            icon: Icons.language,
            title: 'اللغة',
            trailing: 'العربية',
          ),
          const _SettingsTile(icon: Icons.info_outline, title: 'عن التطبيق'),
          const _SettingsTile(icon: Icons.support_agent, title: 'الدعم الفني'),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: ListTile(
              leading: Icon(
                Icons.admin_panel_settings,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              title: Text(
                'البوابة الإدارية',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'إدارة المدرسين، الكورسات، الملازم، والكوبونات',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
              trailing: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              onTap: () => context.goNamed(AppRoute.adminLogin),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إعادة تعيين'),
        content: const Text(
          'هل أنت متأكد؟ سيتم إقفال جميع الكورسات والملازم التي فتحتها '
          'مسبقاً بالكوبونات.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('إعادة التعيين'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(unlockedCoursesProvider.notifier).resetAll();
    await ref.read(unlockedGuidesProvider.notifier).resetAll();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إعادة التعيين')));
    }
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.state});
  final AuthState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, subtitle, signedIn) = switch (state) {
      AuthSignedIn(:final user) => (user.phoneNumber, 'مسجّل دخول', true),
      AuthCodeSent() => (
        'قيد التحقق',
        'انتقل لشاشة الكود لإكمال التسجيل',
        false,
      ),
      AuthError(:final message) => ('خطأ', message, false),
      AuthSignedOut() => (
        'لم تقم بتسجيل الدخول بعد',
        'سجل دخول برقم هاتفك للوصول إلى كورساتك وملازمك',
        false,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: signedIn
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primaryContainer,
              child: Icon(
                signedIn ? Icons.verified_user : Icons.person,
                color: signedIn
                    ? Colors.white
                    : theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textDirection: signedIn
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.icon,
    required this.title,
    required this.count,
  });
  final IconData icon;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, this.trailing});

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: trailing == null
            ? const Icon(Icons.chevron_left)
            : Text(trailing!),
        onTap: () {},
      ),
    );
  }
}
