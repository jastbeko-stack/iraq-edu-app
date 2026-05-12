import 'package:flutter/material.dart';

/// Brand color palette.
///
/// Royal-blue and teal palette inspired by the polished look of leading
/// Arabic edtech platforms. Centralized so theme tweaks happen in one place.
abstract final class AppColors {
  /// Primary brand color — deep royal blue used in the AppBar, primary
  /// buttons, and key emphasis surfaces.
  static const Color primary = Color(0xFF1E5BA8);

  /// Slightly darker variant of [primary], used for gradient ends and
  /// pressed states on dark surfaces.
  static const Color primaryDark = Color(0xFF143F76);

  /// Brighter variant of [primary], used for gradient starts and hover
  /// states.
  static const Color primaryLight = Color(0xFF2A78D2);

  /// Secondary accent — teal, used for action icons, "featured" gradients,
  /// and quick-action tiles.
  static const Color secondary = Color(0xFF1FAFA8);

  /// Accent color used for ratings (stars), highlights, and pricing badges.
  static const Color accent = Color(0xFFF5C518);

  /// Soft red used for notification badges and destructive actions.
  static const Color danger = Color(0xFFE5484D);

  /// Neutral surfaces (page background).
  static const Color surfaceLight = Color(0xFFF4F7FB);
  static const Color surfaceDark = Color(0xFF0E141C);

  /// Card / elevated surface (light mode).
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Semantic tokens.
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
}
