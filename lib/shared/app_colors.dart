import 'package:flutter/material.dart';

/// Single source of truth for PennyPal colors.
/// Every screen and widget reads from here so the brand stays consistent.
class AppColors {
  // Surfaces
  static const background = Color(0xFFF4F5F7);
  static const card = Colors.white;
  static const fill = Color(0xFFF1F2F5);

  // Brand green
  static const green = Color(0xFF16A34A);
  static const greenDark = Color(0xFF0B6E3B);
  static const greenSoft = Color(0xFFDDF3E4);
  static const greenTint = Color(0xFFEFF7F0);

  // Amber
  static const amber = Color(0xFFF59E0B);
  static const amberSoft = Color(0xFFFDEBD0);
  static const amberTint = Color(0xFFFFF8E1);

  // Red
  static const red = Color(0xFFDC2626);
  static const redSoft = Color(0xFFFDE7E9);

  // Purple
  static const purple = Color(0xFF6D5DD3);
  static const purpleSoft = Color(0xFFEDEBFB);

  // Blue
  static const blue = Color(0xFF3B5BFF);
  static const blueSoft = Color(0xFFE7EBFF);

  // Text and lines
  static const ink = Color(0xFF1A1D1F);
  static const muted = Color(0xFF6B7280);
  static const track = Color(0xFFE7E9F0);
  static const hint = Color(0xFF9CA3AF);
  static const fieldFill = Color(0xFFF9FAFB);

  // Aliases kept so older screens keep compiling against one palette.
  static const primary = green;
  static const primaryDark = greenDark;
  static const accent = amber;
  static const title = ink;
  static const body = muted;
  static const textDark = ink;
  static const textMuted = muted;
  static const border = track;
  static const cardBorder = track;
  static const amberBg = amberSoft;
  static const lavender = purpleSoft;
  static const lavenderText = Color(0xFF44506B);
}
