import 'package:flutter/material.dart';

class AppColors {
  // Light Mode
  static const Color purple50 = Color(0xFFFAF5FF);
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color white = Colors.white;
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  
  // Dark Mode
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  static const Color gray950 = Color(0xFF030712);
  static const Color purple900 = Color(0xFF581C87);
  static const Color blue900 = Color(0xFF1E3A8A);

  // Status Colors
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);

  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green800 = Color(0xFF166534);
  static const Color green900 = Color(0xFF14532D);

  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red400 = Color(0xFFF87171);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red800 = Color(0xFF991B1B);
  static const Color red900 = Color(0xFF7F1D1D);
}

class AppGradients {
  static const LinearGradient lightBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.purple50, AppColors.blue50],
  );

  static const LinearGradient darkBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gray900, Color(0xFF1F2937), AppColors.gray900], // approximated via-gray-800
  );

  static const LinearGradient primaryGradientLight = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.purple600, AppColors.blue600],
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6B21A8), Color(0xFF1E3A8A)], // purple-700 to blue-700
  );

  static const LinearGradient cardGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.purple600, AppColors.blue600],
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.purple900, AppColors.blue900],
  );
  
  static const LinearGradient achievementGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.amber400, Color(0xFFF97316)], // orange-500
  );

   static const LinearGradient achievementGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.amber600, Color(0xFFC2410C)], // orange-700
  );
}
