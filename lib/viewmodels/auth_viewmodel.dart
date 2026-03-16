import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();
  late StreamSubscription<AuthState> _authStateSubscription;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  AuthViewModel() {
    _initAuthListener();
  }

  void _initAuthListener() {
    try {
      // Theo dõi trạng thái Supabase Auth
      _authStateSubscription =
          _authService.authStateChanges.listen((AuthState state) {
        _currentUser = state.session?.user;
        _isLoggedIn = state.session?.user != null;
        notifyListeners();
      }, onError: (e) {
        debugPrint('Auth state error: $e');
        _errorMessage = 'Lỗi theo dõi trạng thái đăng nhập';
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error initializing auth listener: $e');
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  // --- ĐĂNG NHẬP GOOGLE BẰNG SUPABASE ---
  Future<bool> loginWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithGoogle();

      // OAuth sẽ mở trình duyệt, trạng thái isLoading sẽ tự tắt khi app reload lại từ Deep Link
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // --- ĐĂNG NHẬP EMAIL/PASSWORD ---
  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signIn(email: email, password: password);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // --- ĐĂNG KÝ TÀI KHOẢN ---
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (password != confirmPassword) {
        _errorMessage = 'Mật khẩu không khớp';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Xử lý thông báo lỗi chuẩn Supabase
  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Email hoặc mật khẩu không chính xác';
        case 'User already registered':
          return 'Email này đã được sử dụng';
        case 'Password should be at least 6 characters.':
          return 'Mật khẩu phải có ít nhất 6 ký tự';
        default:
          return error.message;
      }
    }
    return 'Lỗi: ${error.toString()}';
  }
}
