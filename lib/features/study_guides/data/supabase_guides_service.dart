import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../domain/study_guide.dart';

/// Thin wrapper over Supabase Storage + Postgres for the study-guide catalog.
///
/// All admin mutations from the in-app portal flow through this service so
/// PDFs end up in the `pdfs` bucket and metadata rows end up in the `guides`
/// table. The student-facing UI subscribes to the same table via
/// [supabaseGuidesProvider] so uploads / deletes appear instantly across
/// every device.
class SupabaseGuidesService {
  SupabaseGuidesService(this._client);

  final SupabaseClient _client;

  String get _bucket => SupabaseConfig.pdfBucket;
  String get _table => SupabaseConfig.guidesTable;

  /// Uploads [bytes] under `guides/<guideId>.pdf` (overwriting on collision)
  /// and returns the public URL the student app can hand to `launchUrl`.
  Future<String> uploadPdf({
    required String guideId,
    required Uint8List bytes,
  }) async {
    final objectPath = 'guides/$guideId.pdf';
    await _client.storage
        .from(_bucket)
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true,
          ),
        );
    return _client.storage.from(_bucket).getPublicUrl(objectPath);
  }

  /// Deletes the PDF object whose public URL was previously returned by
  /// [uploadPdf]. Tolerates URLs that don't belong to this bucket (e.g.
  /// guides whose PDFs are hosted elsewhere) by silently no-op'ing.
  Future<void> deletePdfByUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final marker = '/storage/v1/object/public/$_bucket/';
    final i = url.indexOf(marker);
    if (i == -1) return;
    final objectPath = url.substring(i + marker.length);
    if (objectPath.isEmpty) return;
    try {
      await _client.storage.from(_bucket).remove([objectPath]);
    } catch (_) {
      // Already deleted, or RLS blocked it — surfacing the error here would
      // leave a dangling row, so we swallow and let the row delete proceed.
    }
  }

  /// Inserts or updates the guide row. Uses the table's primary key (`id`)
  /// for conflict resolution so the same call covers both create and edit.
  Future<void> upsertGuide(StudyGuide g) async {
    await _client.from(_table).upsert(_toRow(g));
  }

  Future<void> deleteGuide(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  /// Snapshot fetch (used by the initial load in the realtime stream).
  Future<List<StudyGuide>> fetchGuides() async {
    final rows = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: true);
    return rows.map(_fromRow).toList();
  }

  /// Realtime stream of all rows in `guides`, emitted as [StudyGuide]s. The
  /// stream emits the full ordered list on every change (insert / update /
  /// delete) so callers can replace their state wholesale.
  Stream<List<StudyGuide>> streamGuides() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) => rows.map(_fromRow).toList());
  }

  // ─── Row mapping ──────────────────────────────────────────────────────

  Map<String, dynamic> _toRow(StudyGuide g) => {
    'id': g.id,
    'title': g.title,
    'subject': g.subject,
    'author': g.author,
    'track_id': g.trackId,
    'page_count': g.pageCount,
    'size_bytes': g.sizeBytes,
    'price_iqd': g.priceIqd,
    'is_locked': g.isLocked,
    'description': g.description,
    'cover_url': g.coverUrl,
    'preview_pdf_url': g.previewPdfUrl,
    'full_pdf_url': g.fullPdfUrl,
  };

  StudyGuide _fromRow(Map<String, dynamic> row) => StudyGuide(
    id: row['id'] as String,
    title: (row['title'] as String?) ?? '',
    subject: (row['subject'] as String?) ?? '',
    author: (row['author'] as String?) ?? '',
    pageCount: (row['page_count'] as num?)?.toInt() ?? 0,
    sizeBytes: (row['size_bytes'] as num?)?.toInt() ?? 0,
    priceIqd: (row['price_iqd'] as num?)?.toInt() ?? 0,
    isLocked: (row['is_locked'] as bool?) ?? false,
    trackId: (row['track_id'] as String?) ?? '',
    coverUrl: row['cover_url'] as String?,
    description: (row['description'] as String?) ?? '',
    previewPdfUrl: row['preview_pdf_url'] as String?,
    fullPdfUrl: row['full_pdf_url'] as String?,
  );
}

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final supabaseGuidesServiceProvider = Provider<SupabaseGuidesService>(
  (ref) => SupabaseGuidesService(ref.watch(supabaseClientProvider)),
);

/// Realtime stream of guides held in Supabase Postgres. While the first
/// snapshot is loading the provider yields an empty list so callers don't
/// have to handle a loading state — they just see "no remote guides yet".
final supabaseGuidesProvider = StreamProvider<List<StudyGuide>>((ref) {
  final svc = ref.watch(supabaseGuidesServiceProvider);
  return svc.streamGuides();
});

/// Synchronous projection convenient for merging with other guide sources.
final supabaseGuidesListProvider = Provider<List<StudyGuide>>((ref) {
  final async = ref.watch(supabaseGuidesProvider);
  return async.maybeWhen(data: (xs) => xs, orElse: () => const []);
});
