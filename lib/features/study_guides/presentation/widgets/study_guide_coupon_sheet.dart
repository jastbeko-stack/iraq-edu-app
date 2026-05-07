import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/study_guide_repository.dart';
import '../../domain/study_guide.dart';
import '../../domain/study_guide_codes.dart';

/// Bottom-sheet UI for redeeming a **study-guide** coupon.
///
/// Same state machine and ergonomics as the course coupon sheet but bound
/// to the study-guide store so the two namespaces never collide.
class StudyGuideCouponSheet extends ConsumerStatefulWidget {
  const StudyGuideCouponSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const StudyGuideCouponSheet(),
    );
  }

  @override
  ConsumerState<StudyGuideCouponSheet> createState() =>
      _StudyGuideCouponSheetState();
}

enum _SheetStatus { idle, submitting, success, invalid, alreadyOwned }

class _StudyGuideCouponSheetState extends ConsumerState<StudyGuideCouponSheet> {
  final _controller = TextEditingController();
  _SheetStatus _status = _SheetStatus.idle;
  StudyGuideRedemptionResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.isEmpty || _status == _SheetStatus.submitting) return;

    setState(() => _status = _SheetStatus.submitting);
    final result = await ref.read(unlockedGuidesProvider.notifier).redeem(code);
    if (!mounted) return;

    setState(() {
      _result = result;
      _status = switch (result) {
        StudyGuideRedemptionSuccess() => _SheetStatus.success,
        StudyGuideRedemptionInvalid() => _SheetStatus.invalid,
        StudyGuideRedemptionAlreadyOwned() => _SheetStatus.alreadyOwned,
      };
    });

    if (result is StudyGuideRedemptionSuccess) {
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _useDemoCode(String code) {
    _controller.text = code;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: code.length),
    );
    setState(() {
      _status = _SheetStatus.idle;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفعيل ملزمة',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'أدخل كود الملزمة لفتحها وتنزيلها',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
              _UpperCaseTextFormatter(),
              LengthLimitingTextInputFormatter(24),
            ],
            style: theme.textTheme.titleLarge?.copyWith(
              letterSpacing: 4,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'G-XXXX-XXXX',
              hintStyle: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.outline,
                letterSpacing: 4,
              ),
            ),
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_status != _SheetStatus.idle) {
                setState(() {
                  _status = _SheetStatus.idle;
                  _result = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          _StatusBanner(status: _status, result: _result),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _status == _SheetStatus.submitting ? null : _submit,
            icon: _status == _SheetStatus.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Text('تفعيل'),
          ),
          const SizedBox(height: 20),
          _DemoCodesPanel(onTap: _useDemoCode),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status, required this.result});

  final _SheetStatus status;
  final StudyGuideRedemptionResult? result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: switch (status) {
        _SheetStatus.idle || _SheetStatus.submitting => const SizedBox.shrink(),
        _SheetStatus.success => _Banner(
          key: const ValueKey('success'),
          color: theme.colorScheme.primaryContainer,
          foreground: theme.colorScheme.onPrimaryContainer,
          icon: Icons.check_circle,
          title: (result is StudyGuideRedemptionSuccess)
              ? (result! as StudyGuideRedemptionSuccess).coupon.label
              : 'تم التفعيل',
          subtitle:
              'تم فتح ${(result is StudyGuideRedemptionSuccess) ? (result! as StudyGuideRedemptionSuccess).newlyUnlocked.length : ''} ملزمة',
        ),
        _SheetStatus.invalid => _Banner(
          key: const ValueKey('invalid'),
          color: theme.colorScheme.errorContainer,
          foreground: theme.colorScheme.onErrorContainer,
          icon: Icons.error_outline,
          title: 'الكود غير صحيح',
          subtitle: 'تأكد من إدخال كود الملزمة بشكل صحيح',
        ),
        _SheetStatus.alreadyOwned => _Banner(
          key: const ValueKey('owned'),
          color: theme.colorScheme.secondaryContainer,
          foreground: theme.colorScheme.onSecondaryContainer,
          icon: Icons.info_outline,
          title: 'هذا الكوبون مستخدم مسبقاً',
          subtitle: 'الملازم الخاصة به مفتوحة عندك بالفعل',
        ),
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    super.key,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final Color foreground;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCodesPanel extends StatelessWidget {
  const _DemoCodesPanel({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'أكواد تجريبية',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'اضغط على أحد الأكواد التالية لتعبئته تلقائياً',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final code in StudyGuideCodes.demoHintCodes)
                ActionChip(
                  label: Text(
                    code,
                    style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  onPressed: () => onTap(code),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
