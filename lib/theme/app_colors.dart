import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light theme palette.
  static const Color primary = Color(0xFF6D4CC2);
  static const Color secondary = Color(0xFF9B7AD6);
  static const Color accent = Color(0xFFF3A8C8);
  static const Color background = Color(0xFFFFF7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF211B3A);
  static const Color muted = Color(0xFF655D78);
  static const Color error = Color(0xFFC94F6D);
  static const Color success = Color(0xFF54BFA5);

  // Dark theme palette. The same purple/pink identity is kept, but the
  // background and surfaces are darker for comfortable night use.
  static const Color darkBackground = Color(0xFF15121C);
  static const Color darkSurface = Color(0xFF211C2B);
  static const Color darkSurfaceVariant = Color(0xFF2B2537);
  static const Color darkText = Color(0xFFF8F5FC);
  static const Color darkMuted = Color(0xFFB9B1C9);
  static const Color darkPrimary = Color(0xFFAE91E8);
  static const Color darkSecondary = Color(0xFFC2A8EF);
  static const Color darkAccent = Color(0xFFF3A8C8);
}
