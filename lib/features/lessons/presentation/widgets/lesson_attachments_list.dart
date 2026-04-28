import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/models/course.dart';

/// Vertical list of lesson attachments (PDFs, worksheets, slides).
///
/// Tapping an attachment opens it externally via the OS / browser. On web
/// this means the file opens in a new tab; on mobile the OS picks an
/// appropriate viewer (Files / Adobe Reader / etc.).
class LessonAttachmentsList extends StatelessWidget {
  const LessonAttachmentsList({required this.attachments, super.key});

  final List<LessonAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (attachments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'لا توجد مرفقات لهذا الدرس',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final a in attachments)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AttachmentTile(attachment: a),
          ),
      ],
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.attachment});

  final LessonAttachment attachment;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(attachment.url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح المرفق')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => _open(context),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _iconFor(attachment.kind),
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          attachment.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(_subtitle(attachment)),
        trailing: const Icon(Icons.download_outlined),
      ),
    );
  }

  static IconData _iconFor(AttachmentKind kind) => switch (kind) {
    AttachmentKind.pdf => Icons.picture_as_pdf,
    AttachmentKind.worksheet => Icons.assignment_outlined,
    AttachmentKind.slides => Icons.slideshow_outlined,
    AttachmentKind.notes => Icons.sticky_note_2_outlined,
  };

  static String _subtitle(LessonAttachment a) {
    final parts = <String>[a.kind.arabicLabel];
    if (a.sizeBytes != null) parts.add(_humanSize(a.sizeBytes!));
    return parts.join(' • ');
  }

  static String _humanSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(0);
      return '$kb KB';
    }
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
    return '$mb MB';
  }
}
