import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../announcements/data/announcements_service.dart';
import '../../../announcements/domain/announcement.dart';

/// CRUD on `public.announcements`. The first announcement marked active
/// shows up as a banner at the top of the student home screen.
class AdminAnnouncementsTab extends ConsumerWidget {
  const AdminAnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(announcementsStreamProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('تعذر تحميل الإعلانات: $e'),
        ),
      ),
      data: (items) {
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              children: [
                Card(
                  color: theme.colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          color: theme.colorScheme.onTertiaryContainer,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الإعلان النشط يظهر للطلاب',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme
                                      .colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'أحدث إعلان نشط يظهر كبانر بأعلى الصفحة الرئيسية. '
                                'لإخفاءه، أوقفه أو احذفه.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme
                                      .colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'لا إعلانات بعد',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'اضغط زر "+" لإضافة أول إعلان.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...items.map(
                    (a) => _AnnouncementCard(
                      announcement: a,
                      onEdit: () => _showEditor(context, ref, a),
                      onToggle: () => ref
                          .read(announcementsServiceProvider)
                          .setActive(a.id, !a.isActive),
                      onDelete: () => _confirmDelete(context, ref, a),
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () => _showEditor(context, ref, null),
                icon: const Icon(Icons.add),
                label: const Text('إعلان جديد'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref,
    Announcement? existing,
  ) async {
    final result = await showModalBottomSheet<Announcement>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _AnnouncementEditor(existing: existing),
    );
    if (result == null) return;
    await ref.read(announcementsServiceProvider).upsert(result);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Announcement a,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف إعلان'),
        content: Text('سيتم حذف "${a.title}" نهائياً. متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(announcementsServiceProvider).delete(a.id);
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final Announcement announcement;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    announcement.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusChip(isActive: announcement.isActive),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              announcement.body,
              style: theme.textTheme.bodyMedium,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(announcement.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip:
                      announcement.isActive ? 'إيقاف الإعلان' : 'تشغيل الإعلان',
                  icon: Icon(
                    announcement.isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                  ),
                  onPressed: onToggle,
                ),
                IconButton(
                  tooltip: 'تعديل',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: 'حذف',
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.pause_circle,
            size: 14,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'نشط' : 'موقوف',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementEditor extends StatefulWidget {
  const _AnnouncementEditor({required this.existing});
  final Announcement? existing;

  @override
  State<_AnnouncementEditor> createState() => _AnnouncementEditorState();
}

class _AnnouncementEditorState extends State<_AnnouncementEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.existing?.body ?? '');
    _isActive = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.existing;
    // For new rows we send id=''; the service inserts and lets Postgres
    // generate a UUID via gen_random_uuid(). For edits we keep the id.
    final result = Announcement(
      id: existing?.id ?? '',
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
      isActive: _isActive,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding:
          EdgeInsets.fromLTRB(20, 16, 20, 20 + viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.existing == null ? 'إعلان جديد' : 'تعديل الإعلان',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'العنوان',
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: 80,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخل العنوان' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bodyCtrl,
              decoration: const InputDecoration(
                labelText: 'النص',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 400,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخل نص الإعلان' : null,
            ),
            SwitchListTile(
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
              title: const Text('نشط (يظهر للطلاب)'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(widget.existing == null ? 'نشر' : 'حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
