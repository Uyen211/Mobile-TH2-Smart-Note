import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;

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

  // Đăng nhập
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

  // Đăng xuất
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Lấy user hiện tại
  User? get currentUser => _client.auth.currentUser;

  // Lắng nghe trạng thái đăng nhập
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
