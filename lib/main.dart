import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/note_viewmodel.dart';
import 'views/home/home_screen.dart';
import 'core/theme.dart';

void main() {
  // Đảm bảo các dịch vụ của Flutter được khởi tạo trước khi chạy App
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // Cung cấp NoteViewModel cho toàn bộ ứng dụng để quản lý State
        ChangeNotifierProvider(create: (_) => NoteViewModel()),
      ],
      child: const SmartNoteApp(),
    ),
  );
}

class SmartNoteApp extends StatelessWidget {
  const SmartNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ẩn banner Debug cho chuyên nghiệp
      title: 'Smart Note',

      // Sử dụng cấu hình Xanh biển (Blue) chúng ta đã thiết lập
      theme: AppTheme.lightTheme,

      // Nếu bạn chưa định nghĩa darkTheme trong AppTheme,
      // hãy tạm thời để nó sử dụng theme mặc định hoặc lightTheme để tránh lỗi
      themeMode: ThemeMode.light,

      home: const HomeScreen(), // Điểm khởi đầu của ứng dụng
    );
  }
}
