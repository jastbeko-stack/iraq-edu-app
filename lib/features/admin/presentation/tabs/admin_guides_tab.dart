import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../study_guides/data/supabase_guides_service.dart';
import '../../../study_guides/domain/study_guide.dart';
import '../../../tracks/domain/learning_track.dart';
import '../../data/catalog_store.dart';

/// Admin tab for managing study guides backed by Supabase Storage + Postgres.
///
/// Upload flow:
///   1. Admin opens [GuideForm], fills in metadata, picks a PDF via
///      `file_picker` (reads bytes — works on web and mobile).
///   2. On save, the bytes are uploaded to the `pdfs` bucket and the row is
///      upserted into `guides`.
///   3. The Supabase realtime stream pushes the new row to every client
///      including the student-facing `الملازم` screen.
///
/// Delete flow mirrors the upload: the storage object is removed and the
/// row is deleted in the same call.
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
    // Watch the realtime Supabase stream so the list updates instantly when
    // a guide is uploaded / deleted from any device.
    final remoteAsync = ref.watch(supabaseGuidesProvider);
    final localCatalog = ref.watch(studyGuidesProvider);

    final remote = remoteAsync.maybeWhen(
      data: (xs) => xs,
      orElse: () => const <StudyGuide>[],
    );
    // Merge: remote rows win on id collisions (they have real PDFs).
    final merged = <String, StudyGuide>{
      for (final g in localCatalog) g.id: g,
    };
    for (final g in remote) {
      merged[g.id] = g;
    }
    final all = merged.values.toList();
    final filtered = _filter == null
        ? all
        : all.where((g) => g.trackId == _filter!.id).toList();

    return Scaffold(
      body: Column(
        children: [
          if (remoteAsync.isLoading)
            const LinearProgressIndicator(minHeight: 2),
          if (remoteAsync.hasError)
            _RemoteErrorBanner(error: remoteAsync.error),
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
    final result = await showModalBottomSheet<_GuideFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GuideForm(existing: existing),
      ),
    );
    if (result == null) return;
    if (!context.mounted) return;
    await _saveGuide(context, result);
  }

  Future<void> _saveGuide(
    BuildContext context,
    _GuideFormResult result,
  ) async {
    final svc = ref.read(supabaseGuidesServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    // Show a non-dismissible progress dialog while we upload + persist.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      var guide = result.guide;
      if (result.pdfBytes != null) {
        final url = await svc.uploadPdf(
          guideId: guide.id,
          bytes: result.pdfBytes!,
        );
        guide = guide.copyWith(fullPdfUrl: url);
      }
      await svc.upsertGuide(guide);
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close progress
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.isNew ? 'تمت إضافة الملزمة' : 'تم تحديث الملزمة',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      messenger.showSnackBar(
        SnackBar(content: Text('فشل الحفظ: $e')),
      );
    }
  }
}

class _RemoteErrorBanner extends StatelessWidget {
  const _RemoteErrorBanner({required this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: theme.colorScheme.errorContainer,
      child: Text(
        'تعذر الاتصال بقاعدة بيانات الملازم: $error',
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
      ),
    );
  }
}

class _GuideTile extends ConsumerWidget {
  const _GuideTile({required this.guide});
  final StudyGuide guide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final track = LearningTrack.fromId(guide.trackId);
    final hasPdf = guide.fullPdfUrl != null && guide.fullPdfUrl!.isNotEmpty;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hasPdf
              ? theme.colorScheme.tertiaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.picture_as_pdf,
            color: hasPdf
                ? theme.colorScheme.onTertiaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(guide.title),
        subtitle: Text(
          '${guide.subject} · ${guide.pageCount} ص · '
          '${(guide.sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB · '
          '${track?.shortLabel ?? guide.trackId}'
          '${hasPdf ? '' : ' · بدون ملف'}',
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
              onPressed: () => _confirmAndDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الملزمة'),
        content: Text('سيتم حذف "${guide.title}" والملف المرتبط بها. متأكد؟'),
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
    if (confirmed != true || !context.mounted) return;

    final svc = ref.read(supabaseGuidesServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await svc.deletePdfByUrl(guide.fullPdfUrl);
      await svc.deleteGuide(guide.id);
      // Also drop from the local catalog if the id ever lived there.
      try {
        await ref.read(studyGuidesProvider.notifier).deleteById(guide.id);
      } catch (_) {
        // Local catalog never had this id — ignore.
      }
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      messenger.showSnackBar(const SnackBar(content: Text('تم حذف الملزمة')));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      messenger.showSnackBar(SnackBar(content: Text('فشل الحذف: $e')));
    }
  }
}

class _GuideFormResult {
  _GuideFormResult({
    required this.guide,
    required this.pdfBytes,
    required this.isNew,
  });
  final StudyGuide guide;
  final Uint8List? pdfBytes;
  final bool isNew;
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
  Uint8List? _pickedBytes;
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
    // `withData: true` is required on web — bytes come back in `result.files[0].bytes`.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    final bytes = f.bytes;
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر قراءة محتوى الملف')),
      );
      return;
    }
    setState(() {
      _pickedFileName = f.name;
      _pickedBytes = bytes;
      _pickedSizeBytes = bytes.lengthInBytes;
    });
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
                          (widget.existing?.fullPdfUrl != null &&
                                  widget.existing!.fullPdfUrl!.isNotEmpty
                              ? 'ملف موجود — اختر ملف جديد لاستبداله'
                              : 'لم يتم اختيار ملف'),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (_pickedSizeBytes != null && _pickedSizeBytes! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'الحجم: ${(_pickedSizeBytes! / (1024 * 1024)).toStringAsFixed(2)} MB',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('اختر PDF'),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'يُرفع الملف إلى Supabase Storage عند الحفظ.',
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
    // Require a PDF on first creation; allow editing without re-uploading.
    if (widget.existing == null && _pickedBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر ملف PDF أولاً')),
      );
      return;
    }
    final id =
        widget.existing?.id ?? 'g_${DateTime.now().millisecondsSinceEpoch}';
    final guide = StudyGuide(
      id: id,
      title: _title.text.trim(),
      subject: _subject.text.trim(),
      author: _author.text.trim().isEmpty ? 'غير محدد' : _author.text.trim(),
      pageCount: int.tryParse(_pageCount.text.trim()) ?? 0,
      sizeBytes: _pickedSizeBytes ?? widget.existing?.sizeBytes ?? 0,
      priceIqd: int.tryParse(_priceIqd.text.trim()) ?? 0,
      isLocked: _isLocked,
      trackId: _track.id,
      description: _description.text.trim(),
      coverUrl: widget.existing?.coverUrl,
      previewPdfUrl: widget.existing?.previewPdfUrl,
      // Preserve existing URL when editing without replacing the file. Upload
      // step in `_saveGuide` will overwrite this if new bytes were picked.
      fullPdfUrl: widget.existing?.fullPdfUrl,
    );
    Navigator.pop(
      context,
      _GuideFormResult(
        guide: guide,
        pdfBytes: _pickedBytes,
        isNew: widget.existing == null,
      ),
    );
  }
}
