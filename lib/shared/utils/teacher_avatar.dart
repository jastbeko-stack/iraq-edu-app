import 'dart:convert';

import 'package:flutter/widgets.dart';

/// Returns an [ImageProvider] for a teacher avatar URL.
///
/// Avatars uploaded via the admin portal are stored as base64
/// `data:image/...;base64,...` URLs directly in the teacher record so that
/// the feature works without any Supabase Storage / bucket / RLS setup.
/// Avatars sourced from remote URLs (e.g. seeded data) are loaded with
/// [NetworkImage].
ImageProvider? teacherAvatarImage(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('data:')) {
    final commaIndex = url.indexOf(',');
    if (commaIndex == -1) return null;
    try {
      final bytes = base64Decode(url.substring(commaIndex + 1));
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(url);
}
