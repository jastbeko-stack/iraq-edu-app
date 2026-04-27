import 'package:flutter/material.dart';

/// Profile / settings screen.
///
/// Pre-auth state shows a "Sign in" CTA. Once Firebase phone auth lands the
/// signed-in state will surface the user's phone number, language toggle,
/// support links, and logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
