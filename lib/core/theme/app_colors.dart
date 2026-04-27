import 'package:flutter/material.dart';

/// Brand color palette.
///
/// Centralized so theme tweaks happen in one place. Adjust to match the final
/// brand identity once design assets are provided.
abstract final class AppColors {
  /// Primary brand color. Iraqi-flag-inspired deep red, balanced for UI use.
  static const Color primary = Color(0xFFCE1126);

  /// Secondary accent used for highlights and CTAs that should not compete with
  /// the primary color.
  static const Color secondary = Color(0xFF1F6FEB);

  /// Neutral surfaces.
  static const Color surfaceLight = Color(0xFFF7F7F8);
  static const Color surfaceDark = Color(0xFF101114);

  /// Success / warning / error semantic tokens.
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
}
