import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/study_guide.dart';

/// Loads `assets/pdfs/manifest.json` at app start and exposes its entries as
/// [StudyGuide] objects. The student-facing track providers merge these with
/// the seeded sample guides and any admin-portal-added entries so users see
/// one unified list.
///
/// The manifest is the user's "headless CMS" — they edit it directly from
/// VS Code, push to `main`, and the GitHub Action redeploys the app. See
/// `assets/pdfs/README.md` for the schema.
class PdfManifestEntry {
  const PdfManifestEntry({
    required this.id,
    required this.name,
    required this.path,
    required this.trackId,
    required this.subject,
    required this.author,
    this.pageCount = 0,
    this.sizeBytes = 0,
    this.priceIqd = 0,
    this.locked = false,
    this.description = '',
    this.coverUrl,
  });

  final String id;
  final String name;
  final String path;
  final String trackId;
  final String subject;
  final String author;
  final int pageCount;
  final int sizeBytes;
  final int priceIqd;
  final bool locked;
  final String description;
  final String? coverUrl;

  factory PdfManifestEntry.fromJson(Map<String, dynamic> json) =>
      PdfManifestEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        path: json['path'] as String,
        trackId: json['trackId'] as String,
        subject: json['subject'] as String,
        author: json['author'] as String,
        pageCount: (json['pageCount'] as num?)?.toInt() ?? 0,
        sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
        priceIqd: (json['priceIqd'] as num?)?.toInt() ?? 0,
        locked: json['locked'] as bool? ?? false,
        description: (json['description'] as String?) ?? '',
        coverUrl: json['coverUrl'] as String?,
      );

  /// Resolves [path] to a URL the platform's launcher can open.
  ///
  /// * If [path] already starts with `http://` or `https://`, it is returned
  ///   as-is (external link).
  /// * Otherwise it is treated as an asset path relative to the repo root
  ///   (e.g. `assets/pdfs/foo.pdf`) and resolved against the runtime origin.
  ///   Flutter Web copies declared assets into `<origin>/assets/<path>`, so
  ///   the final URL is `<origin>/assets/<path>`.
  String resolveUrl() {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Flutter Web copies declared assets into `<origin>/assets/<path>`.
    // We guard against non-http schemes (e.g. `file://` in unit tests, where
    // `Uri.base.origin` would throw) by falling back to a relative URL.
    final base = Uri.base;
    if (base.scheme == 'http' || base.scheme == 'https') {
      return '${base.origin}/assets/$path';
    }
    return '/assets/$path';
  }

  StudyGuide toStudyGuide() => StudyGuide(
    id: id,
    title: name,
    subject: subject,
    author: author,
    pageCount: pageCount,
    sizeBytes: sizeBytes,
    priceIqd: priceIqd,
    isLocked: locked,
    trackId: trackId,
    coverUrl: coverUrl,
    description: description,
    previewPdfUrl: resolveUrl(),
    fullPdfUrl: resolveUrl(),
  );
}

/// Loads and parses `assets/pdfs/manifest.json`.
///
/// Returns an empty list (and silently swallows errors) when the manifest is
/// missing or malformed so a typo in the file never crashes the whole app.
Future<List<PdfManifestEntry>> _loadManifest() async {
  try {
    final raw = await rootBundle.loadString('assets/pdfs/manifest.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['guides'] as List<dynamic>?) ?? const [];
    return list
        .cast<Map<String, dynamic>>()
        .map(PdfManifestEntry.fromJson)
        .toList(growable: false);
  } catch (_) {
    return const [];
  }
}

/// Async source of truth for guides loaded from the bundled manifest.
final pdfManifestProvider = FutureProvider<List<PdfManifestEntry>>((_) async {
  return _loadManifest();
});

/// Synchronous projection: bundled-manifest entries as [StudyGuide]s. While
/// the manifest is still loading this returns an empty list, so callers can
/// merge with other guide sources without having to await.
final manifestStudyGuidesProvider = Provider<List<StudyGuide>>((ref) {
  final async = ref.watch(pdfManifestProvider);
  return async.maybeWhen(
    data: (entries) => entries.map((e) => e.toStudyGuide()).toList(),
    orElse: () => const [],
  );
});
