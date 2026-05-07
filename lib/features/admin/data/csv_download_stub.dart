import 'package:flutter/services.dart';

/// Non-web fallback: copy the CSV to the clipboard so the admin can paste
/// it into Excel / Google Sheets / WhatsApp.
Future<void> downloadCsv(String csv, String filename) async {
  await Clipboard.setData(ClipboardData(text: csv));
}
