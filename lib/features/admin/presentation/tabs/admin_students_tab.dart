import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/csv_download.dart';
import '../../data/students_service.dart';

/// Read-only list of registered students with search, CSV export, and
/// per-row delete. Streamed from `public.profiles`.
class AdminStudentsTab extends ConsumerStatefulWidget {
  const AdminStudentsTab({super.key});

  @override
  ConsumerState<AdminStudentsTab> createState() => _AdminStudentsTabState();
}

class _AdminStudentsTabState extends ConsumerState<AdminStudentsTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Defer to next frame so we're not modifying state during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(studentsLastSeenProvider.notifier).markSeenNow();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(studentsStreamProvider);
    final lastSeen = ref.watch(studentsLastSeenProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'تعذر تحميل قائمة الطلاب',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '$e',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (students) {
        final filtered = _filter(students, _query);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryCard(total: students.length, shown: filtered.length),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم أو البريد',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            ),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: students.isEmpty
                      ? null
                      : () => _exportCsv(students),
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('CSV'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              _EmptyState(filtered: students.isNotEmpty)
            else
              ...filtered.map(
                (s) => _StudentCard(
                  student: s,
                  isNew: lastSeen != null && s.createdAt.isAfter(lastSeen),
                  onDelete: () => _confirmDelete(s),
                ),
              ),
          ],
        );
      },
    );
  }

  List<StudentProfile> _filter(List<StudentProfile> all, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((s) {
      return s.displayName.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q);
    }).toList(growable: false);
  }

  Future<void> _exportCsv(List<StudentProfile> students) async {
    final csv = StudentsService.toCsv(students);
    final stamp = DateTime.now().toIso8601String().split('.').first;
    final filename = 'students-$stamp.csv';
    await downloadCsv(csv, filename);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تصدير ${students.length} طالب إلى $filename'),
      ),
    );
  }

  Future<void> _confirmDelete(StudentProfile s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: Text(
          'سيتم حذف حساب "${s.displayName}" (${s.email}) نهائياً. '
          'لن يقدر صاحبه على تسجيل الدخول مرة أخرى. متأكد؟',
        ),
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
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(studentsServiceProvider).deleteStudent(s.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف ${s.displayName}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر الحذف: $e')),
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total, required this.shown});
  final int total;
  final int shown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtering = shown != total;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.groups, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filtering ? 'النتائج المعروضة' : 'إجمالي الطلاب المسجّلين',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    filtering ? '$shown / $total' : '$total',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.isNew,
    required this.onDelete,
  });
  final StudentProfile student;
  final bool isNew;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            student.displayName.isNotEmpty
                ? student.displayName.characters.first.toUpperCase()
                : '?',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                student.displayName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'جديد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              student.email,
              textDirection: TextDirection.ltr,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(student.createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          tooltip: 'حذف الحساب',
          icon: Icon(
            Icons.delete_outline,
            color: theme.colorScheme.error,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return 'سجّل في $y-$m-$d  $hh:$mm';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered});
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          Icon(
            filtered ? Icons.search_off : Icons.person_add_alt_1_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            filtered ? 'لا نتائج للبحث' : 'لم يسجّل أي طالب بعد',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            filtered
                ? 'جرّب اسماً أو بريداً مختلفاً.'
                : 'سيظهر هنا كل طالب يسجّل حساب جديد، فور إنشاء الحساب.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
