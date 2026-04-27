import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../coupons/data/coupon_repository.dart';
import '../../coupons/presentation/coupon_redemption_sheet.dart';

/// Profile / settings screen.
///
/// Pre-auth state shows a "Sign in" CTA. Once Firebase phone auth lands the
/// signed-in state will surface the user's phone number, language toggle,
/// support links, and logout.
///
/// While the app is in demo mode (no backend) this screen also exposes:
/// - a count of unlocked courses,
/// - a quick coupon redemption shortcut,
/// - a "reset unlocks" action so reviewers can re-test the coupon flow.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unlockedCount = ref.watch(unlockedCoursesProvider).length;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لم تقم بتسجيل الدخول بعد',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'سجل دخول برقم هاتفك للوصول إلى كورساتك',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.login),
            label: const Text('تسجيل الدخول'),
          ),
          const SizedBox(height: 24),
          _SectionLabel(text: 'كورساتي'),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.lock_open, color: theme.colorScheme.primary),
              title: const Text('الكورسات المفتوحة'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  unlockedCount.toString(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.confirmation_number_outlined),
              title: const Text('تفعيل كوبون'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => CouponRedemptionSheet.show(context),
            ),
          ),
          if (unlockedCount > 0)
            Card(
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(
                  Icons.refresh,
                  color: theme.colorScheme.onErrorContainer,
                ),
                title: Text(
                  'إعادة تعيين الكورسات (تجريبي)',
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'يمسح كل الكورسات التي فتحتها بالكوبونات',
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                onTap: () => _confirmReset(context, ref),
              ),
            ),
          const SizedBox(height: 16),
          _SectionLabel(text: 'الإعدادات'),
          const SizedBox(height: 8),
          const _SettingsTile(
            icon: Icons.language,
            title: 'اللغة',
            trailing: 'العربية',
          ),
          const _SettingsTile(icon: Icons.info_outline, title: 'عن التطبيق'),
          const _SettingsTile(icon: Icons.support_agent, title: 'الدعم الفني'),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إعادة تعيين الكورسات'),
        content: const Text(
          'هل أنت متأكد؟ سيتم إقفال جميع الكورسات التي فتحتها مسبقاً '
          'بالكوبونات.',
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
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إعادة التعيين')));
    }
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
