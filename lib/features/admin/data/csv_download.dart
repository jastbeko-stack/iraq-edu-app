// Cross-platform entry point for triggering a CSV download from the admin
// portal. On web we hand a Blob to the browser via an `<a download>`
// anchor; on mobile/desktop we fall back to copying the text to the
// clipboard since the admin portal is currently web-first.
//
// The actual implementation lives in `csv_download_web.dart` /
// `csv_download_stub.dart` and is selected via conditional import.

export 'csv_download_stub.dart' if (dart.library.html) 'csv_download_web.dart';
