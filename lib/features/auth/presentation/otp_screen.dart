import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_controller.dart';
import '../domain/auth_state.dart';

/// 6-digit OTP entry screen.
///
/// - Single `TextField` with monospaced styling and digit-only input.
/// - 60-second resend cooldown timer.
/// - On `AuthSignedIn` pops back to whatever pushed [LoginScreen].
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _codeController = TextEditingController();
  Timer? _resendTimer;
  int _resendIn = 60;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendIn = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_resendIn > 0) {
          _resendIn -= 1;
        } else {
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_submitting) return;
    final code = _codeController.text.trim();
    if (code.length != 6) return;

    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).verifyCode(code);
    if (!mounted) return;
    setState(() => _submitting = false);

    final state = ref.read(authControllerProvider);
    if (state is AuthSignedIn) {
      // Pop back through the LoginScreen → caller.
      int popped = 0;
      Navigator.of(context).popUntil((_) => popped++ >= 2);
    }
  }

  Future<void> _resend() async {
    if (_resendIn > 0) return;
    await ref.read(authControllerProvider.notifier).resendCode();
    if (!mounted) return;
    _startResendTimer();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم إعادة إرسال الكود')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(authControllerProvider);
    final phone = switch (state) {
      AuthCodeSent(:final phoneNumber) => phoneNumber,
      AuthError(:final previous) when previous is AuthCodeSent =>
        previous.phoneNumber,
      _ => null,
    };
    final errorMessage = state is AuthError ? state.message : null;

    return Scaffold(
      appBar: AppBar(title: const Text('رمز التحقق')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              'أدخل الرمز المكوّن من ٦ أرقام المرسل إلى',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            if (phone != null)
              Text(
                phone,
                textDirection: TextDirection.ltr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: theme.textTheme.headlineMedium?.copyWith(
                letterSpacing: 16,
                fontWeight: FontWeight.w800,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '••••••',
              ),
              onSubmitted: (_) => _verify(),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submitting ? null : _verify,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.verified_user),
              label: const Text('تحقق'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _resendIn > 0 ? null : _resend,
              icon: const Icon(Icons.refresh),
              label: Text(
                _resendIn > 0
                    ? 'إعادة إرسال بعد $_resendIn ثانية'
                    : 'إعادة إرسال الكود',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: theme.colorScheme.primary, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'كود الديمو: ${AuthController.stubVerificationCode}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
