import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_config.dart';
import '../../../../shared/models/teacher.dart';
import '../../../tracks/domain/learning_track.dart';
import '../../data/catalog_store.dart';

class AdminTeachersTab extends ConsumerStatefulWidget {
  const AdminTeachersTab({super.key});

  @override
  ConsumerState<AdminTeachersTab> createState() => _AdminTeachersTabState();
}

class _AdminTeachersTabState extends ConsumerState<AdminTeachersTab> {
  LearningTrack? _filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = ref.watch(teachersProvider);
    final filtered = _filter == null
        ? all
        : all.where((t) => t.trackId == _filter!.id).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ChoiceChip(
                          label: const Text('الكل'),
                          selected: _filter == null,
                          onSelected: (_) => setState(() => _filter = null),
                        ),
                        const SizedBox(width: 8),
                        for (final t in LearningTrack.values) ...[
                          ChoiceChip(
                            avatar: Icon(t.icon, size: 16),
                            label: Text(t.shortLabel),
                            selected: _filter == t,
                            onSelected: (_) => setState(() => _filter = t),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (filtered.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'لا يوجد مدرسون',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _TeacherTile(teacher: filtered[i]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('مدرس جديد'),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {Teacher? existing}) async {
    final saved = await showModalBottomSheet<Teacher>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TeacherForm(existing: existing),
      ),
    );
    if (saved != null) {
      await ref.read(teachersProvider.notifier).upsert(saved);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null ? 'تمت إضافة المدرس' : 'تم تحديث المدرس',
          ),
        ),
      );
    }
  }
}

class _TeacherTile extends ConsumerWidget {
  const _TeacherTile({required this.teacher});

  final Teacher teacher;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final track = LearningTrack.fromId(teacher.trackId);

    final avatarUrl = teacher.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
          child: hasAvatar
              ? null
              : Text(
                  teacher.name.characters.first,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
        title: Text(teacher.name),
        subtitle: Text(
          '${teacher.subject} · ${track?.shortLabel ?? teacher.trackId}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'تعديل',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  (context.findAncestorStateOfType<_AdminTeachersTabState>())!
                      ._openForm(context, existing: teacher),
            ),
            IconButton(
              tooltip: 'حذف',
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف المدرس'),
                    content: Text('سيتم حذف ${teacher.name}. هل أنت متأكد؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref
                      .read(teachersProvider.notifier)
                      .deleteById(teacher.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TeacherForm extends StatefulWidget {
  const TeacherForm({this.existing, super.key});
  final Teacher? existing;

  @override
  State<TeacherForm> createState() => _TeacherFormState();
}

class _TeacherFormState extends State<TeacherForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _subject;
  late final TextEditingController _bio;
  late final TextEditingController _coursesCount;
  late final TextEditingController _studentsCount;
  late LearningTrack _track;

  /// In-memory bytes of an image picked but not yet uploaded.
  Uint8List? _pickedBytes;
  String? _pickedExt;

  /// Persisted public URL of the saved avatar (either pre-existing or just
  /// uploaded). When the user picks a new image but hasn't saved yet, we keep
  /// the previous URL here for the "existing" case so canceling doesn't lose
  /// the old avatar.
  String? _avatarUrl;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _subject = TextEditingController(text: e?.subject ?? '');
    _bio = TextEditingController(text: e?.bio ?? '');
    _coursesCount = TextEditingController(
      text: (e?.coursesCount ?? 0).toString(),
    );
    _studentsCount = TextEditingController(
      text: (e?.studentsCount ?? 0).toString(),
    );
    _track = e == null
        ? LearningTrack.preparatory
        : LearningTrack.fromId(e.trackId) ?? LearningTrack.preparatory;
    _avatarUrl = e?.avatarUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _subject.dispose();
    _bio.dispose();
    _coursesCount.dispose();
    _studentsCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'إضافة مدرس' : 'تعديل المدرس',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _AvatarPicker(
              bytes: _pickedBytes,
              url: _avatarUrl,
              name: _name.text,
              onPick: _pickAvatar,
              onClear: _clearAvatar,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<LearningTrack>(
              initialValue: _track,
              decoration: const InputDecoration(
                labelText: 'القسم',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                for (final t in LearningTrack.values)
                  DropdownMenuItem(
                    value: t,
                    child: Row(
                      children: [
                        Icon(t.icon, size: 18),
                        const SizedBox(width: 8),
                        Text(t.label),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _track = v ?? _track),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _subject,
              decoration: const InputDecoration(
                labelText: 'المادة',
                prefixIcon: Icon(Icons.book_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخل المادة' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _bio,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'نبذة',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _coursesCount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'عدد الكورسات',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _studentsCount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'عدد الطلاب'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('حفظ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = result?.files.firstOrNull;
    final bytes = file?.bytes;
    if (bytes == null) return;
    setState(() {
      _pickedBytes = bytes;
      _pickedExt = (file?.extension ?? 'jpg').toLowerCase();
    });
  }

  void _clearAvatar() {
    setState(() {
      _pickedBytes = null;
      _pickedExt = null;
      _avatarUrl = null;
    });
  }

  Future<String?> _uploadAvatarIfNeeded(String teacherId) async {
    final bytes = _pickedBytes;
    if (bytes == null) return _avatarUrl;
    final ext = _pickedExt ?? 'jpg';
    final objectPath = 'teacher-avatars/$teacherId.$ext';
    final storage = Supabase.instance.client.storage.from(
      SupabaseConfig.pdfBucket,
    );
    await storage.uploadBinary(
      objectPath,
      bytes,
      fileOptions: FileOptions(
        contentType: _mimeFor(ext),
        upsert: true,
      ),
    );
    final publicUrl = storage.getPublicUrl(objectPath);
    // Append a cache-buster so the new image shows immediately when the same
    // path is overwritten on an edit.
    return '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  String _mimeFor(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_submitting) return;
    setState(() => _submitting = true);
    final id =
        widget.existing?.id ?? 't_${DateTime.now().millisecondsSinceEpoch}';
    String? avatarUrl;
    try {
      avatarUrl = await _uploadAvatarIfNeeded(id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر رفع الصورة: $e')),
      );
      return;
    }
    final teacher = Teacher(
      id: id,
      name: _name.text.trim(),
      subject: _subject.text.trim(),
      bio: _bio.text.trim(),
      coursesCount: int.tryParse(_coursesCount.text.trim()) ?? 0,
      studentsCount: int.tryParse(_studentsCount.text.trim()) ?? 0,
      trackId: _track.id,
      avatarUrl: avatarUrl,
    );
    if (!mounted) return;
    Navigator.pop(context, teacher);
  }
}

/// Round avatar preview with a primary button to pick a new image and a
/// secondary action to clear the current avatar. Shows the freshly picked
/// bytes if any, otherwise the persisted URL, otherwise an initial-letter
/// placeholder.
class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.bytes,
    required this.url,
    required this.name,
    required this.onPick,
    required this.onClear,
  });

  final Uint8List? bytes;
  final String? url;
  final String name;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = bytes != null || (url != null && url!.isNotEmpty);
    final initial = name.trim().isEmpty ? 'م' : name.trim()[0];
    ImageProvider? provider;
    if (bytes != null) {
      provider = MemoryImage(bytes!);
    } else if (url != null && url!.isNotEmpty) {
      provider = NetworkImage(url!);
    }
    return Row(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          backgroundImage: provider,
          child: provider == null
              ? Text(
                  initial,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.image_outlined),
                label: Text(hasImage ? 'تغيير الصورة' : 'اختر صورة'),
              ),
              if (hasImage) ...[
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('إزالة الصورة'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
