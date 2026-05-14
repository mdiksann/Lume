import 'package:flutter/material.dart';

/// Curated color palette for the Lume brand.
///
/// Warm, literary-inspired tones designed to evoke the feeling
/// of reading by candlelight — ivory backgrounds, deep navy text,
/// and amber accents.
class AppColors {
  AppColors._();

  // ──────────────────────────────────────────────
  // Light Mode
  // ──────────────────────────────────────────────

  /// Warm ivory background
  static const Color lightBackground = Color(0xFFFAF8F5);

  /// Slightly warmer surface for cards
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Deep navy — primary brand color
  static const Color lightPrimary = Color(0xFF1B2838);

  /// Warm amber accent — for actions and highlights
  static const Color lightAccent = Color(0xFFD4A853);

  /// Muted amber for secondary highlights
  static const Color lightAccentMuted = Color(0xFFE8D5A8);

  /// Primary text — deep charcoal
  static const Color lightTextPrimary = Color(0xFF1B2838);

  /// Secondary text — warm grey
  static const Color lightTextSecondary = Color(0xFF7A7670);

  /// Tertiary text — light warm grey
  static const Color lightTextTertiary = Color(0xFFB0AAA2);

  /// Divider color
  static const Color lightDivider = Color(0xFFEDE9E3);

  /// Error / destructive action
  static const Color lightError = Color(0xFFCF6679);

  // ──────────────────────────────────────────────
  // Dark Mode
  // ──────────────────────────────────────────────

  /// Deep charcoal background
  static const Color darkBackground = Color(0xFF121212);

  /// Slightly lighter surface for cards
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// Soft ivory — primary in dark mode
  static const Color darkPrimary = Color(0xFFFAF8F5);

  /// Warm amber accent — consistent across modes
  static const Color darkAccent = Color(0xFFD4A853);

  /// Muted amber for dark mode
  static const Color darkAccentMuted = Color(0xFF5C4A28);

  /// Primary text — near-white
  static const Color darkTextPrimary = Color(0xFFF5F0EB);

  /// Secondary text — muted warm grey
  static const Color darkTextSecondary = Color(0xFF9E9890);

  /// Tertiary text — dimmed
  static const Color darkTextTertiary = Color(0xFF6B665E);

  /// Divider color
  static const Color darkDivider = Color(0xFF2C2C2C);

  /// Error / destructive action
  static const Color darkError = Color(0xFFCF6679);

  // ──────────────────────────────────────────────
  // Shared
  // ──────────────────────────────────────────────

  /// Star rating gold
  static const Color starGold = Color(0xFFFFB800);

  /// Success green
  static const Color success = Color(0xFF4CAF50);
}
