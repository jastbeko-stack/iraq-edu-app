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
