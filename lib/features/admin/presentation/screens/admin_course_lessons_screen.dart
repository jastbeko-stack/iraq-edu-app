import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/course.dart' show Course;
import '../../../lessons/data/lessons_service.dart';
import '../../../lessons/domain/lesson.dart';
import '../../data/catalog_store.dart';

/// Admin-only screen for managing the video lessons of a single [Course].
///
/// Shows the current ordered list of lessons (from the Supabase realtime
/// stream) and exposes a bottom-sheet form to add or edit one. Each form
/// submission uploads the picked video file to the `videos` bucket and
/// upserts the matching row in `public.lessons`.
class AdminCourseLessonsScreen extends ConsumerWidget {
  const AdminCourseLessonsScreen({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final coursesAsync = ref.watch(coursesProvider);
    final Course? course = coursesAsync
        .where((c) => c.id == courseId)
        .cast<Course?>()
        .firstOrNull;
    final lessons = ref.watch(lessonsForCourseProvider(courseId));
    final streamState = ref.watch(lessonsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(course == null ? 'دروس الكورس' : 'دروس: ${course.title}'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openLessonForm(context, ref, course: course),
        icon: const Icon(Icons.add),
        label: const Text('درس جديد'),
      ),
      body: streamState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'تعذّر تحميل الدروس من السيرفر:\n$e\n\n'
              'تأكّد من تشغيل سكربت SQL لإنشاء جدول lessons و bucket videos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
        data: (_) {
          if (lessons.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.ondemand_video_outlined,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'ما في دروس بعد لهذا الكورس',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'اضغط "درس جديد" أسفل الشاشة لرفع أوّل فيديو.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: lessons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final lesson = lessons[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(lesson.title),
                  subtitle: Text(
                    lesson.isFreePreview
                        ? 'معاينة مجانية'
                        : (lesson.description.isEmpty
                              ? 'مدفوع'
                              : lesson.description),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'تعديل',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openLessonForm(
                          context,
                          ref,
                          course: course,
                          existing: lesson,
                        ),
                      ),
                      IconButton(
                        tooltip: 'حذف',
                        icon: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () => _confirmDelete(context, ref, lesson),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openLessonForm(
    BuildContext context,
    WidgetRef ref, {
    required Course? course,
    Lesson? existing,
  }) async {
    if (course == null) return;
    final existingCount = ref.read(lessonsForCourseProvider(courseId)).length;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _LessonForm(
          courseId: course.id,
          existing: existing,
          nextOrderIndex: existing?.orderIndex ?? existingCount,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Lesson lesson,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الدرس'),
        content: Text(
          'سيتم حذف الدرس "${lesson.title}" والفيديو المرفق به. متأكد؟',
        ),
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
    if (confirmed != true) return;
    final svc = ref.read(lessonsServiceProvider);
    try {
      await svc.deleteVideoByUrl(lesson.videoUrl);
      await svc.deleteLesson(lesson.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف الدرس')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذّر الحذف: $e')));
    }
  }
}

class _LessonForm extends ConsumerStatefulWidget {
  const _LessonForm({
    required this.courseId,
    required this.nextOrderIndex,
    this.existing,
  });

  final String courseId;
  final Lesson? existing;
  final int nextOrderIndex;

  @override
  ConsumerState<_LessonForm> createState() => _LessonFormState();
}

class _LessonFormState extends ConsumerState<_LessonForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late bool _isFreePreview;

  Uint8List? _pickedBytes;
  String? _pickedName;
  String? _pickedExt;
  String? _existingVideoUrl;

  bool _submitting = false;
  double? _uploadProgress;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _isFreePreview = e?.isFreePreview ?? false;
    _existingVideoUrl = e?.videoUrl;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'إضافة درس' : 'تعديل الدرس',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'عنوان الدرس',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'أدخل عنوان الدرس' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _description,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'وصف (اختياري)',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('معاينة مجانية'),
              subtitle: const Text(
                'الدرس متاح بدون كوبون (الافتراضي: مدفوع)',
              ),
              value: _isFreePreview,
              onChanged: (v) => setState(() => _isFreePreview = v),
            ),
            const SizedBox(height: 6),
            _VideoPickRow(
              fileName: _pickedName,
              hasExisting: _existingVideoUrl != null,
              onPick: _pickVideo,
              onClear: _clearPickedVideo,
            ),
            if (_uploadProgress != null) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: 4),
              Text(
                'جاري الرفع… ${((_uploadProgress ?? 0) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_submitting ? 'جاري الحفظ…' : 'حفظ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );
    final file = result?.files.firstOrNull;
    final bytes = file?.bytes;
    if (bytes == null || file == null) return;
    // Cap at 200 MB per upload to keep the free Supabase tier happy and avoid
    // browser memory pressure on web.
    const maxBytes = 200 * 1024 * 1024;
    if (bytes.length > maxBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الفيديو أكبر من 200 ميغا. ضغّطه أو اختر ملف أصغر.'),
        ),
      );
      return;
    }
    setState(() {
      _pickedBytes = bytes;
      _pickedName = file.name;
      _pickedExt = (file.extension ?? 'mp4').toLowerCase();
    });
  }

  void _clearPickedVideo() {
    setState(() {
      _pickedBytes = null;
      _pickedName = null;
      _pickedExt = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedBytes == null && _existingVideoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر ملف فيديو قبل الحفظ')),
      );
      return;
    }
    setState(() {
      _submitting = true;
      _uploadProgress = _pickedBytes == null ? null : 0;
    });
    final svc = ref.read(lessonsServiceProvider);
    try {
      String videoUrl = _existingVideoUrl ?? '';
      if (_pickedBytes != null) {
        // Generate a temporary id for new lessons so the object path is
        // stable; for edits we keep the existing id and replace the file.
        final lessonId =
            widget.existing?.id ?? 'l_${DateTime.now().millisecondsSinceEpoch}';
        videoUrl = await svc.uploadVideo(
          courseId: widget.courseId,
          lessonId: lessonId,
          bytes: _pickedBytes!,
          fileExtension: _pickedExt ?? 'mp4',
        );
        // Bust browser cache when the same path is overwritten.
        videoUrl = '$videoUrl?v=${DateTime.now().millisecondsSinceEpoch}';

        if (widget.existing == null) {
          await svc.insertLesson(
            Lesson(
              id: lessonId,
              courseId: widget.courseId,
              title: _title.text.trim(),
              description: _description.text.trim(),
              videoUrl: videoUrl,
              orderIndex: widget.nextOrderIndex,
              isFreePreview: _isFreePreview,
            ),
          );
        } else {
          await svc.updateLesson(
            widget.existing!.copyWith(
              title: _title.text.trim(),
              description: _description.text.trim(),
              videoUrl: videoUrl,
              isFreePreview: _isFreePreview,
            ),
          );
        }
      } else {
        // Metadata-only edit (no new file).
        await svc.updateLesson(
          widget.existing!.copyWith(
            title: _title.text.trim(),
            description: _description.text.trim(),
            isFreePreview: _isFreePreview,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ الدرس')));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _uploadProgress = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذّر الحفظ: $e')));
    }
  }
}

class _VideoPickRow extends StatelessWidget {
  const _VideoPickRow({
    required this.fileName,
    required this.hasExisting,
    required this.onPick,
    required this.onClear,
  });

  final String? fileName;
  final bool hasExisting;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = fileName != null
        ? fileName!
        : (hasExisting ? 'فيديو محفوظ مسبقاً' : 'لم يتم اختيار فيديو');
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.video_file_outlined),
            label: Text(
              fileName == null ? 'اختر ملف فيديو' : 'تغيير الفيديو',
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (fileName != null)
          IconButton(
            tooltip: 'إزالة',
            onPressed: onClear,
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          ),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
