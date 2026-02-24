import 'package:flutter/material.dart';

class AppColors {
  // Định nghĩa bảng màu Xanh biển (Ocean Blue) chuyên nghiệp
  static const Color primary = Color(0xFF0277BD);
  static const Color primaryLight = Color(0xFF58A5F0);
  static const Color primaryDark = Color(0xFF004C8C);
  static const Color background =
      Color.fromARGB(255, 191, 223, 255); // Xanh nhạt rất dịu
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      // ignore: deprecated_member_use
      background: AppColors.background,
      error: AppColors.error,
    ),

    cardTheme: CardThemeData(
      elevation: 2, // Đổ bóng nhẹ theo yêu cầu [cite: 48, 647]
      color: AppColors.surface,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12), // Bo góc 12px chuẩn [cite: 50, 647]
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 2,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),

    // Cấu hình TextTheme đồng bộ
    textTheme: const TextTheme(
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      bodySmall: TextStyle(
        fontSize: 11,
        color: Colors.grey,
      ),
    ),
  );
}
