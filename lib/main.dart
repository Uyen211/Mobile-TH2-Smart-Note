// main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'viewmodels/note_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/home/home_screen.dart';
import 'views/auth/login_screen.dart';
import 'core/theme.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_options.dart';

void main() async {
  // Đảm bảo các dịch vụ của Flutter được khởi tạo trước khi chạy App
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khởi tạo Supabase
  await Supabase.initialize(
    url: SupabaseOptions.supabaseUrl,
    anonKey: SupabaseOptions.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        // Cung cấp AuthViewModel để quản lý trạng thái đăng nhập
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
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

      home: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          // Nếu user đã đăng nhập, hiển thị HomeScreen
          // Nếu chưa đăng nhập, hiển thị LoginScreen
          return authVM.isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
