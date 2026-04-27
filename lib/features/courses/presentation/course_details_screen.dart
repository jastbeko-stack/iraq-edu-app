import 'package:flutter/material.dart';

import '../../../shared/models/sample_data.dart';

/// Detail view for a single course: cover, description, lessons list, and
/// CTAs for enrolling or redeeming a coupon.
///
/// Coupon redemption and Bunny.net video playback are stubs in this
/// scaffolding pass — they will be wired to Cloud Functions in a follow-up.
class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    final course = SampleData.courseById(courseId);
    final theme = Theme.of(context);

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الكورس')),
        body: const Center(child: Text('الكورس غير موجود')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: AlignmentDirectional.bottomStart,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  course.subject,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  course.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  course.teacherName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (course.isLocked)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: theme.colorScheme.onErrorContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'هذا الكورس مقفل، يرجى الاشتراك أو استخدام كوبون لفتحه',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('اشتراك بالكورس'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCouponSheet(context),
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: const Text('كوبون'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'عن الكورس',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(course.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text(
            'الدروس',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...SampleData.sampleLessons.map(
            (l) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    l.isFreePreview ? Icons.play_arrow : Icons.lock_outline,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(l.title),
                subtitle: Text('${l.durationMinutes} دقيقة'),
                trailing: l.isFreePreview
                    ? Chip(
                        label: const Text('عرض مجاني'),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        side: BorderSide.none,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCouponSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'استخدام كوبون',
              style: Theme.of(
                sheetContext,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'XXXX-XXXX-XXXX',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: const Text('تفعيل'),
            ),
          ],
        ),
      ),
    );
  }
}
