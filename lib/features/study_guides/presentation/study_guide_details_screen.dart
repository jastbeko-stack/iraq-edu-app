import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../admin/data/catalog_store.dart';
import '../data/study_guide_repository.dart';
import 'widgets/study_guide_coupon_sheet.dart';

/// Detail page for a single ملزمة. Shows full description and a primary
/// CTA: "تنزيل" if unlocked (or always-free), or "تفعيل بكوبون" otherwise.
class StudyGuideDetailsScreen extends ConsumerWidget {
  const StudyGuideDetailsScreen({required this.guideId, super.key});

  final String guideId;

  Future<void> _open(BuildContext context, String? url) async {
    if (url == null) return;
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح الملف')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final guide = ref.watch(studyGuideByIdProvider(guideId));
    if (guide == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ملزمة')),
        body: const Center(child: Text('الملزمة غير موجودة')),
      );
    }

    final unlocked = ref.watch(isGuideUnlockedProvider(guide.id));
    final available = !guide.isLocked || unlocked;

    return Scaffold(
      appBar: AppBar(title: Text(guide.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    size: 72,
                    color: Colors.white70,
                  ),
                ),
                PositionedDirectional(
                  start: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: available
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          available ? Icons.lock_open : Icons.lock,
                          size: 14,
                          color: available
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          available ? 'مفعّلة' : 'مقفلة',
                          style: TextStyle(
                            color: available
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            guide.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            guide.author,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Stat(icon: Icons.book, label: guide.subject),
              _Stat(icon: Icons.menu_book, label: '${guide.pageCount} صفحة'),
              _Stat(
                icon: Icons.attach_file,
                label: _humanSize(guide.sizeBytes),
              ),
              if (!available)
                _Stat(icon: Icons.payments, label: '${guide.priceIqd} د.ع'),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'وصف الملزمة',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(guide.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          if (available)
            FilledButton.icon(
              onPressed: () => _open(context, guide.fullPdfUrl),
              icon: const Icon(Icons.download),
              label: const Text('تنزيل الملزمة'),
            )
          else ...[
            FilledButton.icon(
              onPressed: () => StudyGuideCouponSheet.show(context),
              icon: const Icon(Icons.confirmation_number_outlined),
              label: const Text('تفعيل بكوبون'),
            ),
            if (guide.previewPdfUrl != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _open(context, guide.previewPdfUrl),
                icon: const Icon(Icons.preview),
                label: const Text('معاينة مجانية'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _humanSize(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
