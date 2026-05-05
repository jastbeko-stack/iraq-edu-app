import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../study_guides/data/supabase_guides_service.dart'
    show supabaseClientProvider;
import '../domain/announcement.dart';

/// CRUD + realtime stream for `public.announcements`.
class AnnouncementsService {
  AnnouncementsService(this._client);

  final SupabaseClient _client;
  static const String _table = 'announcements';

  Stream<List<Announcement>> streamAll() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map(
          (rows) => rows
              .map(Announcement.fromRow)
              .toList(growable: false)
              .reversed
              .toList(growable: false),
        );
  }

  Future<void> upsert(Announcement a) async {
    if (a.id.isEmpty) {
      // Let Postgres generate the UUID via gen_random_uuid().
      await _client.from(_table).insert({
        'title': a.title,
        'body': a.body,
        'is_active': a.isActive,
      });
    } else {
      await _client.from(_table).update({
        'title': a.title,
        'body': a.body,
        'is_active': a.isActive,
      }).eq('id', a.id);
    }
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  Future<void> setActive(String id, bool isActive) async {
    await _client.from(_table).update({'is_active': isActive}).eq('id', id);
  }
}

final announcementsServiceProvider = Provider<AnnouncementsService>(
  (ref) => AnnouncementsService(ref.watch(supabaseClientProvider)),
);

/// All announcements newest-first, used by the admin tab.
final announcementsStreamProvider =
    StreamProvider<List<Announcement>>((ref) {
  return ref.watch(announcementsServiceProvider).streamAll();
});

/// The newest active announcement (if any), used by the student home banner.
final activeAnnouncementProvider = Provider<Announcement?>((ref) {
  final async = ref.watch(announcementsStreamProvider);
  return async.maybeWhen(
    data: (list) {
      for (final a in list) {
        if (a.isActive) return a;
      }
      return null;
    },
    orElse: () => null,
  );
});
