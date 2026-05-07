import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/course.dart';
import '../../../../shared/models/teacher.dart';
import '../../../tracks/domain/learning_track.dart';
import '../../data/catalog_store.dart';

class AdminCoursesTab extends ConsumerStatefulWidget {
  const AdminCoursesTab({super.key});

  @override
  ConsumerState<AdminCoursesTab> createState() => _AdminCoursesTabState();
}

class _AdminCoursesTabState extends ConsumerState<AdminCoursesTab> {
  LearningTrack? _filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = ref.watch(coursesProvider);
    final filtered = _filter == null
        ? all
        : all.where((c) => c.trackId == _filter!.id).toList();

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
                  'لا توجد كورسات',
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
                itemBuilder: (context, i) => _CourseTile(course: filtered[i]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('كورس جديد'),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {Course? existing}) async {
    final teachers = ref.read(teachersProvider);
    final saved = await showModalBottomSheet<Course>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CourseForm(existing: existing, teachers: teachers),
      ),
    );
    if (saved != null) {
      await ref.read(coursesProvider.notifier).upsert(saved);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null ? 'تمت إضافة الكورس' : 'تم تحديث الكورس',
          ),
        ),
      );
    }
  }
}

class _CourseTile extends ConsumerWidget {
  const _CourseTile({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final track = LearningTrack.fromId(course.trackId);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            Icons.menu_book,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(course.title),
        subtitle: Text(
          '${course.teacherName} · ${course.lessonsCount} درس · '
          '${track?.shortLabel ?? course.trackId}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              course.isLocked ? Icons.lock : Icons.lock_open,
              size: 18,
              color: course.isLocked
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
            IconButton(
              tooltip: 'تعديل',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  (context.findAncestorStateOfType<_AdminCoursesTabState>())!
                      ._openForm(context, existing: course),
            ),
            IconButton(
              tooltip: 'حذف',
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف الكورس'),
                    content: Text('سيتم حذف "${course.title}". متأكد؟'),
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
                      .read(coursesProvider.notifier)
                      .deleteById(course.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CourseForm extends StatefulWidget {
  const CourseForm({required this.teachers, this.existing, super.key});

  final List<Teacher> teachers;
  final Course? existing;

  @override
  State<CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends State<CourseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _subject;
  late final TextEditingController _description;
  late final TextEditingController _lessonsCount;
  late LearningTrack _track;
  Teacher? _teacher;
  late bool _isLocked;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _subject = TextEditingController(text: e?.subject ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _lessonsCount = TextEditingController(
      text: (e?.lessonsCount ?? 8).toString(),
    );
    _track = e == null
        ? LearningTrack.preparatory
        : LearningTrack.fromId(e.trackId) ?? LearningTrack.preparatory;
    _isLocked = e?.isLocked ?? true;
    _teacher = e == null
        ? null
        : widget.teachers.firstWhere(
            (t) => t.id == e.teacherId,
            orElse: () => widget.teachers.isEmpty
                ? throw StateError('No teachers — add one first')
                : widget.teachers.first,
          );
  }

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    _description.dispose();
    _lessonsCount.dispose();
    super.dispose();
  }

  List<Teacher> get _teachersInTrack =>
      widget.teachers.where((t) => t.trackId == _track.id).toList();

  @override
  Widget build(BuildContext context) {
    final teachersInTrack = _teachersInTrack;
    if (_teacher != null && _teacher!.trackId != _track.id) {
      _teacher = null;
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null ? 'إضافة كورس' : 'تعديل الكورس',
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
              if (teachersInTrack.isEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'لا يوجد مدرسون في هذا القسم. أضف مدرساً أولاً.',
                  ),
                )
              else
                DropdownButtonFormField<Teacher>(
                  initialValue: _teacher,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'المدرس',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: [
                    for (final t in teachersInTrack)
                      DropdownMenuItem(
                        value: t,
                        child: Text(
                          '${t.name} — ${t.subject}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  validator: (v) => v == null ? 'اختر مدرساً' : null,
                  onChanged: (v) => setState(() => _teacher = v),
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'عنوان الكورس',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'أدخل العنوان' : null,
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
                controller: _description,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lessonsCount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد الدروس',
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('مقفل (يحتاج كوبون)'),
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
                      onPressed: teachersInTrack.isEmpty ? null : _submit,
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
    final teacher = _teacher;
    if (teacher == null) return;
    final id =
        widget.existing?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}';
    final course = Course(
      id: id,
      title: _title.text.trim(),
      teacherId: teacher.id,
      teacherName: teacher.name,
      subject: _subject.text.trim(),
      lessonsCount: int.tryParse(_lessonsCount.text.trim()) ?? 0,
      isLocked: _isLocked,
      trackId: _track.id,
      description: _description.text.trim(),
    );
    Navigator.pop(context, course);
  }
}
