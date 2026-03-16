import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseClient get _client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw Exception('Supabase chưa được khởi tạo: $e');
    }
  }

  // Đăng ký tài khoản mới
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    return response;
  }

  // Đăng nhập bằng Email/Password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Đăng nhập bằng Google - Web & Mobile compatible
  Future<bool> signInWithGoogle() async {
    try {
      // Web: Không dùng redirectTo, Supabase tự handle callback
      // Mobile: Dùng deep link
      if (kIsWeb) {
        // Web: Supabase sẽ tự handle redirect callback
        // Không cần chỉ định redirectTo
        final result = await _client.auth.signInWithOAuth(
          OAuthProvider.google,
        );
        return result;
      } else {
        // Mobile: Dùng deep link
        final result = await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'io.supabase.smartnote://login-callback/',
        );
        return result;
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      throw Exception('Lỗi đăng nhập Google: $e');
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Lấy user hiện tại
  User? get currentUser => _client.auth.currentUser;

  // Lắng nghe trạng thái đăng nhập
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
