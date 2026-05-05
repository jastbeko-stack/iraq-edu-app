import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../coupons/data/coupon_repository.dart' show sharedPreferencesProvider;
import '../../study_guides/data/supabase_guides_service.dart'
    show supabaseClientProvider;

/// A row in `public.profiles`, mirroring `auth.users` for admin display.
class StudentProfile {
  const StudentProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  static StudentProfile fromRow(Map<String, dynamic> row) {
    final createdRaw = row['created_at'];
    final created = createdRaw is String
        ? DateTime.tryParse(createdRaw) ?? DateTime.now()
        : DateTime.now();
    final email = (row['email'] as String?) ?? '';
    final name = (row['display_name'] as String?)?.trim();
    return StudentProfile(
      uid: (row['id'] as String?) ?? '',
      email: email,
      displayName:
          (name == null || name.isEmpty) ? _fallbackName(email) : name,
      createdAt: created,
    );
  }

  static String _fallbackName(String email) {
    final at = email.indexOf('@');
    if (at <= 0) return email;
    return email.substring(0, at);
  }
}

/// Read-only access to the profiles table. Admin-only via the in-portal
/// session — students never reach this code path.
class StudentsService {
  StudentsService(this._client);

  final SupabaseClient _client;
  static const String _table = 'profiles';

  /// Realtime stream of all student profiles, newest first.
  Stream<List<StudentProfile>> streamStudents() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map(
          (rows) => rows
              .map(StudentProfile.fromRow)
              .toList(growable: false)
              .reversed
              .toList(growable: false),
        );
  }

  /// Permanently deletes a student account, removing both the row in
  /// `auth.users` (which cascades to `public.profiles` via FK) and any
  /// session that account had. Backed by a `security definer` SQL function
  /// so the anon client can call it from the admin portal.
  Future<void> deleteStudent(String studentId) async {
    await _client.rpc(
      'admin_delete_student',
      params: {'student_id': studentId},
    );
  }

  /// Renders the current student list to a UTF-8 CSV string with a BOM so
  /// Excel opens it with the right encoding even on Windows. Columns:
  /// name, email, signup_at_iso, signup_at_local.
  static String toCsv(List<StudentProfile> students) {
    final buf = StringBuffer('\uFEFF'); // BOM for Excel
    buf.writeln('name,email,signup_at_utc,signup_at_local');
    for (final s in students) {
      final local = s.createdAt.toLocal();
      buf.writeln([
        _csv(s.displayName),
        _csv(s.email),
        _csv(s.createdAt.toUtc().toIso8601String()),
        _csv('${local.year.toString().padLeft(4, '0')}-'
            '${local.month.toString().padLeft(2, '0')}-'
            '${local.day.toString().padLeft(2, '0')} '
            '${local.hour.toString().padLeft(2, '0')}:'
            '${local.minute.toString().padLeft(2, '0')}'),
      ].join(','));
    }
    return buf.toString();
  }

  static String _csv(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }
}

final studentsServiceProvider = Provider<StudentsService>(
  (ref) => StudentsService(ref.watch(supabaseClientProvider)),
);

final studentsStreamProvider = StreamProvider<List<StudentProfile>>((ref) {
  final svc = ref.watch(studentsServiceProvider);
  return svc.streamStudents();
});

/// Tracks the timestamp of the last time the admin viewed the students tab,
/// so we can flag rows newer than that as "new since last visit".
const _kStudentsLastSeenKey = 'admin_students_last_seen_v1';

class StudentsLastSeenController extends StateNotifier<DateTime?> {
  StudentsLastSeenController(this._prefs)
      : super(_load(_prefs));

  final SharedPreferences _prefs;

  static DateTime? _load(SharedPreferences prefs) {
    final ms = prefs.getInt(_kStudentsLastSeenKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markSeenNow() async {
    final now = DateTime.now();
    await _prefs.setInt(_kStudentsLastSeenKey, now.millisecondsSinceEpoch);
    state = now;
  }
}

final studentsLastSeenProvider =
    StateNotifierProvider<StudentsLastSeenController, DateTime?>(
  (ref) => StudentsLastSeenController(ref.watch(sharedPreferencesProvider)),
);

/// Number of student rows whose `created_at` is newer than the last time
/// the admin opened the students tab. Used for the unread-badge.
final newStudentsCountProvider = Provider<int>((ref) {
  final async = ref.watch(studentsStreamProvider);
  final lastSeen = ref.watch(studentsLastSeenProvider);
  return async.maybeWhen(
    data: (list) {
      if (lastSeen == null) return list.length;
      return list.where((s) => s.createdAt.isAfter(lastSeen)).length;
    },
    orElse: () => 0,
  );
});
