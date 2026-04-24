import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF10B981); // Emerald Green
  static const Color primaryDark = Color(0xFF059669);
  static const Color secondary = Color(0xFF3B82F6); // Blue
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color accent = Color(0xFFF59E0B); // Amber
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
