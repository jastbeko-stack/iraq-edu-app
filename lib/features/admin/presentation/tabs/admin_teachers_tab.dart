import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final id =
        widget.existing?.id ?? 't_${DateTime.now().millisecondsSinceEpoch}';
    final teacher = Teacher(
      id: id,
      name: _name.text.trim(),
      subject: _subject.text.trim(),
      bio: _bio.text.trim(),
      coursesCount: int.tryParse(_coursesCount.text.trim()) ?? 0,
      studentsCount: int.tryParse(_studentsCount.text.trim()) ?? 0,
      trackId: _track.id,
    );
    Navigator.pop(context, teacher);
  }
}
