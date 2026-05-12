import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_controller.dart';
import '../domain/auth_state.dart';
import 'signup_screen.dart';

/// Full-screen welcome / sign-in gate shown when the app first opens.
///
/// Mirrors the "جامعة المعقل" inspiration the user shared:
///   - Dark canvas
///   - Brand mark + welcome line
///   - 2-step form: email → password
///   - Email + password primary action, Google OAuth secondary,
///     Apple placeholder (disabled), create-account link, footer.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _step = 0; // 0 = email, 1 = password
  bool _submitting = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _validEmail(String v) {
    final t = v.trim();
    return t.contains('@') && t.contains('.');
  }

  Future<void> _next() async {
    if (_step == 0) {
      if (!_validEmail(_emailCtrl.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أدخل بريدًا إلكترونيًا صالحًا.')),
        );
        return;
      }
      setState(() => _step = 1);
      return;
    }
    if (_passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل كلمة المرور.')),
      );
      return;
    }
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailCtrl.text,
          password: _passCtrl.text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ref.read(authControllerProvider) is AuthSignedIn) {
      // The router redirect handles the navigation to /, but we also push
      // here for the (rare) case where redirect is suppressed.
      context.goNamed(AppRoute.home);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _submitting = false);
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل بريدك أولاً ثم اضغط على "نسيت كلمة المرور؟".'),
        ),
      );
      return;
    }
    final ok =
        await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أرسلنا رابط استعادة كلمة المرور إلى $email.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(authControllerProvider);
    final errorMessage = state is AuthError ? state.message : null;

    return Scaffold(
      backgroundColor: const Color(0xFF050B17),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    // Brand mark
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: AppColors.primaryLight,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'منصة المهندس',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _step == 0 ? 'مرحبًا بك مجددًا' : 'أدخل كلمة المرور',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Role picker: student (stays on this screen) vs teacher
                    // (jumps to the admin / teacher portal).
                    Row(
                      children: [
                        Expanded(
                          child: _RoleCard(
                            icon: Icons.person_outline,
                            label: 'طالب',
                            selected: true,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RoleCard(
                            icon: Icons.cast_for_education_outlined,
                            label: 'تدريسي',
                            selected: false,
                            onTap: () => context.go('/admin/login'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Step indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'من 2',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${_step + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _step == 0 ? 'الخطوة الأولى' : 'الخطوة الثانية',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _step == 0
                          ? _DarkField(
                              key: const ValueKey('email'),
                              controller: _emailCtrl,
                              hint: 'اسم المستخدم أو البريد الإلكتروني',
                              icon: Icons.person_outline,
                              keyboardType: TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                            )
                          : Column(
                              key: const ValueKey('password'),
                              children: [
                                _DarkField(
                                  controller: _passCtrl,
                                  hint: 'كلمة المرور',
                                  icon: Icons.lock_outline,
                                  obscure: _obscure,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white54,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscure = !_obscure,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: TextButton(
                                    onPressed: _forgotPassword,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primaryLight,
                                    ),
                                    child: const Text('نسيت كلمة المرور؟'),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Color(0xFFFFB4B4)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Primary action button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _submitting ? null : _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : Text(
                                _step == 0 ? 'متابعة' : 'تسجيل الدخول',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    if (_step == 1) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => setState(() => _step = 0),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text('رجوع'),
                      ),
                    ],
                    const SizedBox(height: 18),
                    // "or" divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Colors.white24, height: 1),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'أو',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Colors.white24, height: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Google
                    _OAuthButton(
                      label: 'تسجيل الدخول بـ Google',
                      onPressed: _submitting ? null : _googleSignIn,
                      leading: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'G',
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Apple (placeholder, disabled until Apple Developer is set up)
                    _OAuthButton(
                      label: 'تسجيل الدخول باستخدام Apple',
                      filledLight: true,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تسجيل الدخول بـ Apple قريباً.',
                            ),
                          ),
                        );
                      },
                      leading: const Icon(
                        Icons.apple,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Create account
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('إنشاء حساب جديد'),
                    ),
                    const SizedBox(height: 28),
                    // Footer
                    Center(
                      child: Icon(
                        Icons.favorite,
                        color: AppColors.danger.withValues(alpha: 0.7),
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'حقوق الطبع والنشر © 2024 - 2025',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'منصة المهندس التعليمية',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A flat dark-themed input field that matches the reference design.
class _DarkField extends StatelessWidget {
  const _DarkField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textDirection,
    this.suffix,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111A2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        textDirection: textDirection,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white54),
          suffixIcon: suffix,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 8,
          ),
        ),
      ),
    );
  }
}

/// Top-of-screen role selector card. The student card is "selected" by
/// default — the rest of this screen IS the student sign-in flow. Tapping
/// the teacher card jumps to the dedicated admin / teacher portal.
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.22)
              : const Color(0xFF111A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primaryLight
                : Colors.white12,
            width: selected ? 1.4 : 0.8,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: selected ? AppColors.primaryLight : Colors.white70,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.label,
    required this.onPressed,
    required this.leading,
    this.filledLight = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget leading;
  final bool filledLight;

  @override
  Widget build(BuildContext context) {
    final bg = filledLight ? Colors.white : const Color(0xFF111A2A);
    final fg = filledLight ? Colors.black : Colors.white;
    return SizedBox(
      height: 50,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: filledLight ? Colors.transparent : Colors.white12,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              leading,
            ],
          ),
        ),
      ),
    );
  }
}
