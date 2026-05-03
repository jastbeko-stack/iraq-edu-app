import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../study_guides/domain/study_guide.dart';
import '../../../tracks/domain/learning_track.dart';
import '../../data/catalog_store.dart';

class AdminGuidesTab extends ConsumerStatefulWidget {
  const AdminGuidesTab({super.key});

  @override
  ConsumerState<AdminGuidesTab> createState() => _AdminGuidesTabState();
}

class _AdminGuidesTabState extends ConsumerState<AdminGuidesTab> {
  LearningTrack? _filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = ref.watch(studyGuidesProvider);
    final filtered = _filter == null
        ? all
        : all.where((g) => g.trackId == _filter!.id).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
          if (filtered.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'لا توجد ملازم',
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
                itemBuilder: (context, i) => _GuideTile(guide: filtered[i]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('ملزمة جديدة'),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {StudyGuide? existing}) async {
    final saved = await showModalBottomSheet<StudyGuide>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GuideForm(existing: existing),
      ),
    );
    if (saved != null) {
      await ref.read(studyGuidesProvider.notifier).upsert(saved);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null ? 'تمت إضافة الملزمة' : 'تم تحديث الملزمة',
          ),
        ),
      );
    }
  }
}

class _GuideTile extends ConsumerWidget {
  const _GuideTile({required this.guide});
  final StudyGuide guide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final track = LearningTrack.fromId(guide.trackId);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.tertiaryContainer,
          child: Icon(
            Icons.picture_as_pdf,
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
        title: Text(guide.title),
        subtitle: Text(
          '${guide.subject} · ${guide.pageCount} ص · '
          '${(guide.sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB · '
          '${track?.shortLabel ?? guide.trackId}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              guide.isLocked ? Icons.lock : Icons.lock_open,
              size: 18,
              color: guide.isLocked
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
            IconButton(
              tooltip: 'تعديل',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  (context.findAncestorStateOfType<_AdminGuidesTabState>())!
                      ._openForm(context, existing: guide),
            ),
            IconButton(
              tooltip: 'حذف',
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف الملزمة'),
                    content: Text('سيتم حذف "${guide.title}". متأكد؟'),
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
                      .read(studyGuidesProvider.notifier)
                      .deleteById(guide.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GuideForm extends StatefulWidget {
  const GuideForm({this.existing, super.key});
  final StudyGuide? existing;

  @override
  State<GuideForm> createState() => _GuideFormState();
}

class _GuideFormState extends State<GuideForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _subject;
  late final TextEditingController _author;
  late final TextEditingController _description;
  late final TextEditingController _pageCount;
  late final TextEditingController _priceIqd;
  late LearningTrack _track;
  late bool _isLocked;
  String? _pickedFileName;
  int? _pickedSizeBytes;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _subject = TextEditingController(text: e?.subject ?? '');
    _author = TextEditingController(text: e?.author ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _pageCount = TextEditingController(text: (e?.pageCount ?? 80).toString());
    _priceIqd = TextEditingController(text: (e?.priceIqd ?? 5000).toString());
    _track = e == null
        ? LearningTrack.preparatory
        : LearningTrack.fromId(e.trackId) ?? LearningTrack.preparatory;
    _isLocked = e?.isLocked ?? true;
    _pickedSizeBytes = e?.sizeBytes;
  }

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    _author.dispose();
    _description.dispose();
    _pageCount.dispose();
    _priceIqd.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    // Demo "upload": prompt for filename + size in MB. Real file upload
    // requires Storage (Firebase / Bunny) which is intentionally deferred.
    final result = await showDialog<({String name, int sizeBytes})>(
      context: context,
      builder: (ctx) {
        final nameCtrl = TextEditingController(
          text: _pickedFileName ?? 'guide.pdf',
        );
        final sizeCtrl = TextEditingController(
          text: _pickedSizeBytes != null
              ? (_pickedSizeBytes! / (1024 * 1024)).toStringAsFixed(1)
              : '5.0',
        );
        return AlertDialog(
          title: const Text('بيانات ملف PDF (تجريبي)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'اسم الملف'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sizeCtrl,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(labelText: 'الحجم (MB)'),
              ),
              const SizedBox(height: 8),
              const Text(
                'الرفع الحقيقي يحتاج Storage. هنا نخزّن الاسم والحجم فقط.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final mb = double.tryParse(sizeCtrl.text.trim()) ?? 0;
                Navigator.pop(ctx, (
                  name: nameCtrl.text.trim(),
                  sizeBytes: (mb * 1024 * 1024).round(),
                ));
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      setState(() {
        _pickedFileName = result.name;
        _pickedSizeBytes = result.sizeBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null ? 'إضافة ملزمة' : 'تعديل الملزمة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
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
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'عنوان الملزمة',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل العنوان' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _subject,
                      decoration: const InputDecoration(labelText: 'المادة'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'أدخل المادة'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _author,
                      decoration: const InputDecoration(labelText: 'المؤلف'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _description,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'الوصف'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pageCount,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'عدد الصفحات',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _priceIqd,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'السعر (د.ع)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ملف PDF',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _pickedFileName ??
                          (_pickedSizeBytes != null
                              ? 'ملف موجود (${(_pickedSizeBytes! / (1024 * 1024)).toStringAsFixed(1)}MB)'
                              : 'لم يتم اختيار ملف'),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('اختر PDF'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'محلي فقط: نخزّن اسم الملف وحجمه. الرفع الفعلي يحتاج Storage.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('مقفلة (تحتاج كوبون)'),
                value: _isLocked,
                onChanged: (v) => setState(() => _isLocked = v),
              ),
              const SizedBox(height: 10),
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
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final id =
        widget.existing?.id ?? 'g_${DateTime.now().millisecondsSinceEpoch}';
    final guide = StudyGuide(
      id: id,
      title: _title.text.trim(),
      subject: _subject.text.trim(),
      author: _author.text.trim().isEmpty ? 'غير محدد' : _author.text.trim(),
      pageCount: int.tryParse(_pageCount.text.trim()) ?? 0,
      sizeBytes: _pickedSizeBytes ?? 0,
      priceIqd: int.tryParse(_priceIqd.text.trim()) ?? 0,
      isLocked: _isLocked,
      trackId: _track.id,
      description: _description.text.trim(),
    );
    Navigator.pop(context, guide);
  }
}
