import 'package:flutter/material.dart';

/// AppColors — Design token warna untuk SimakIn
/// Sesuai dengan Figma design SMKN 1 MGL
class AppColors {
  AppColors._();

  // ─── Primary (Blue) ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFFEFF6FF);

  // ─── Background & Surface ──────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF9FAFB);

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // ─── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);

  // ─── Menu Icon Backgrounds ─────────────────────────────────────────────────
  static const Color menuBlue = Color(0xFFEFF6FF);
  static const Color menuYellow = Color(0xFFFFFBEB);
  static const Color menuGreen = Color(0xFFF0FDF4);
  static const Color menuGray = Color(0xFFF3F4F6);

  // ─── Borders ───────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
}
