import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color navy = Color(0xFF1A237E);
  static const Color navyLight = Color(0xFF283593);
  static const Color navyDark = Color(0xFF0D1642);

  // Accent
  static const Color teal = Color(0xFF00BFA5);
  static const Color tealLight = Color(0xFF64FFDA);
  static const Color tealDark = Color(0xFF00897B);

  // Highlight
  static const Color amber = Color(0xFFFFB300);
  static const Color amberLight = Color(0xFFFFD54F);

  // Backgrounds
  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF1A237E);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [navy, Color(0xFF283593)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [teal, Color(0xFF00E5CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [amber, Color(0xFFFFCA28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyTealGradient = LinearGradient(
    colors: [navy, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
