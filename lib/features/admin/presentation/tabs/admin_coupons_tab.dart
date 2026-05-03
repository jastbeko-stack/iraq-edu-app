import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../coupons/domain/coupon.dart';
import '../../../study_guides/domain/study_guide.dart';
import '../../../tracks/domain/learning_track.dart';
import '../../data/catalog_store.dart';

class AdminCouponsTab extends ConsumerWidget {
  const AdminCouponsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: const [
          Material(
            child: TabBar(
              tabs: [
                Tab(text: 'كوبونات الكورسات'),
                Tab(text: 'كوبونات الملازم'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [_CourseCouponsList(), _GuideCouponsList()],
            ),
          ),
        ],
      ),
    );
  }
}

String _generateCode(String prefix) {
  final rand = Random.secure();
  String chunk() => List.generate(
    4,
    (_) => 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'[rand.nextInt(32)],
  ).join();
  return '$prefix${chunk()}-${chunk()}';
}

// ─── Course coupons ──────────────────────────────────────────────────────

class _CourseCouponsList extends ConsumerWidget {
  const _CourseCouponsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final coupons = ref.watch(courseCouponsProvider);
    return Scaffold(
      body: coupons.isEmpty
          ? Center(
              child: Text('لا توجد كوبونات', style: theme.textTheme.bodyMedium),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: coupons.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _CouponCard(coupon: coupons[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openGenerator(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('توليد كوبون'),
      ),
    );
  }

  Future<void> _openGenerator(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<Coupon>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const _CourseCouponGenerator(),
      ),
    );
    if (result != null) {
      await ref.read(courseCouponsProvider.notifier).upsert(result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم توليد الكوبون: ${result.code}')),
      );
    }
  }
}

class _CouponCard extends ConsumerWidget {
  const _CouponCard({required this.coupon});
  final Coupon coupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Row(
          children: [
            Icon(Icons.confirmation_number, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    coupon.code,
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(coupon.label, style: theme.textTheme.bodySmall),
                  Text(
                    'يفعّل ${coupon.courseIds.length} كورس',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'نسخ',
              icon: const Icon(Icons.copy_all_outlined),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: coupon.code));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('تم نسخ الكوبون')));
              },
            ),
            IconButton(
              tooltip: 'حذف',
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف الكوبون'),
                    content: Text('سيتم حذف ${coupon.code}'),
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
                      .read(courseCouponsProvider.notifier)
                      .deleteByCode(coupon.code);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCouponGenerator extends ConsumerStatefulWidget {
  const _CourseCouponGenerator();

  @override
  ConsumerState<_CourseCouponGenerator> createState() =>
      _CourseCouponGeneratorState();
}

class _CourseCouponGeneratorState
    extends ConsumerState<_CourseCouponGenerator> {
  LearningTrack _track = LearningTrack.preparatory;
  final Set<String> _selectedCourses = {};
  final _labelCtrl = TextEditingController(text: 'كوبون مولّد');
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _codeCtrl.text = _generateCode(_prefixForTrack(_track));
  }

  String _prefixForTrack(LearningTrack t) => switch (t) {
    LearningTrack.preparatory => 'PREP-',
    LearningTrack.engineering => 'ENG-',
    LearningTrack.medical => 'MED-',
  };

  @override
  void dispose() {
    _labelCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = ref
        .watch(coursesProvider)
        .where((c) => c.trackId == _track.id)
        .toList();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'توليد كوبون كورسات',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<LearningTrack>(
              initialValue: _track,
              decoration: const InputDecoration(labelText: 'القسم'),
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
              onChanged: (v) => setState(() {
                _track = v ?? _track;
                _selectedCourses.clear();
                _codeCtrl.text = _generateCode(_prefixForTrack(_track));
              }),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _labelCtrl,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _codeCtrl,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(labelText: 'الكود'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'توليد جديد',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() {
                    _codeCtrl.text = _generateCode(_prefixForTrack(_track));
                  }),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'الكورسات (${_selectedCourses.length} مختارة)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            if (courses.isEmpty)
              const Text('لا توجد كورسات في هذا القسم')
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in courses)
                    FilterChip(
                      label: Text(c.title),
                      selected: _selectedCourses.contains(c.id),
                      onSelected: (sel) => setState(() {
                        if (sel) {
                          _selectedCourses.add(c.id);
                        } else {
                          _selectedCourses.remove(c.id);
                        }
                      }),
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
                    onPressed:
                        _selectedCourses.isEmpty ||
                            _codeCtrl.text.trim().isEmpty
                        ? null
                        : () {
                            Navigator.pop(
                              context,
                              Coupon(
                                code: _codeCtrl.text.trim().toUpperCase(),
                                courseIds: _selectedCourses.toList(),
                                label: _labelCtrl.text.trim().isEmpty
                                    ? 'كوبون مولّد'
                                    : _labelCtrl.text.trim(),
                              ),
                            );
                          },
                    icon: const Icon(Icons.check),
                    label: const Text('توليد'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Guide coupons ───────────────────────────────────────────────────────

class _GuideCouponsList extends ConsumerWidget {
  const _GuideCouponsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final coupons = ref.watch(guideCouponsProvider);
    return Scaffold(
      body: coupons.isEmpty
          ? Center(
              child: Text('لا توجد كوبونات', style: theme.textTheme.bodyMedium),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: coupons.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _GuideCouponCard(coupon: coupons[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openGenerator(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('توليد كوبون'),
      ),
    );
  }

  Future<void> _openGenerator(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<StudyGuideCoupon>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const _GuideCouponGenerator(),
      ),
    );
    if (result != null) {
      await ref.read(guideCouponsProvider.notifier).upsert(result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم توليد الكوبون: ${result.code}')),
      );
    }
  }
}

class _GuideCouponCard extends ConsumerWidget {
  const _GuideCouponCard({required this.coupon});
  final StudyGuideCoupon coupon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Row(
          children: [
            Icon(Icons.confirmation_number, color: theme.colorScheme.tertiary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    coupon.code,
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(coupon.label, style: theme.textTheme.bodySmall),
                  Text(
                    'يفعّل ${coupon.guideIds.length} ملزمة',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'نسخ',
              icon: const Icon(Icons.copy_all_outlined),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: coupon.code));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('تم نسخ الكوبون')));
              },
            ),
            IconButton(
              tooltip: 'حذف',
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف الكوبون'),
                    content: Text('سيتم حذف ${coupon.code}'),
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
                      .read(guideCouponsProvider.notifier)
                      .deleteByCode(coupon.code);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideCouponGenerator extends ConsumerStatefulWidget {
  const _GuideCouponGenerator();

  @override
  ConsumerState<_GuideCouponGenerator> createState() =>
      _GuideCouponGeneratorState();
}

class _GuideCouponGeneratorState extends ConsumerState<_GuideCouponGenerator> {
  LearningTrack _track = LearningTrack.preparatory;
  final Set<String> _selected = {};
  final _labelCtrl = TextEditingController(text: 'كوبون ملازم مولّد');
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _codeCtrl.text = _generateCode(_prefixForTrack(_track));
  }

  String _prefixForTrack(LearningTrack t) => switch (t) {
    LearningTrack.preparatory => 'G-PREP-',
    LearningTrack.engineering => 'G-ENG-',
    LearningTrack.medical => 'G-MED-',
  };

  @override
  void dispose() {
    _labelCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guides = ref
        .watch(studyGuidesProvider)
        .where((g) => g.trackId == _track.id)
        .toList();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'توليد كوبون ملازم',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<LearningTrack>(
              initialValue: _track,
              decoration: const InputDecoration(labelText: 'القسم'),
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
              onChanged: (v) => setState(() {
                _track = v ?? _track;
                _selected.clear();
                _codeCtrl.text = _generateCode(_prefixForTrack(_track));
              }),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _labelCtrl,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _codeCtrl,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(labelText: 'الكود'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'توليد جديد',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() {
                    _codeCtrl.text = _generateCode(_prefixForTrack(_track));
                  }),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'الملازم (${_selected.length} مختارة)',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            if (guides.isEmpty)
              const Text('لا توجد ملازم في هذا القسم')
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final g in guides)
                    FilterChip(
                      label: Text(g.title),
                      selected: _selected.contains(g.id),
                      onSelected: (sel) => setState(() {
                        if (sel) {
                          _selected.add(g.id);
                        } else {
                          _selected.remove(g.id);
                        }
                      }),
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
                    onPressed:
                        _selected.isEmpty || _codeCtrl.text.trim().isEmpty
                        ? null
                        : () {
                            Navigator.pop(
                              context,
                              StudyGuideCoupon(
                                code: _codeCtrl.text.trim().toUpperCase(),
                                guideIds: _selected.toList(),
                                label: _labelCtrl.text.trim().isEmpty
                                    ? 'كوبون مولّد'
                                    : _labelCtrl.text.trim(),
                              ),
                            );
                          },
                    icon: const Icon(Icons.check),
                    label: const Text('توليد'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
