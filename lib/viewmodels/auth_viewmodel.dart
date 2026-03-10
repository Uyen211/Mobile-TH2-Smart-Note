import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

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
    // Theo dõi trạng thái authentication ngay khi khởi tạo
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      _isLoggedIn = user != null;
      notifyListeners();
    });
  }

  // Đăng ký tài khoản mới
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
  }) async {
    try {
      if (password != confirmPassword) {
        _errorMessage = 'Mật khẩu không khớp';
        notifyListeners();
        return false;
      }
      if (fullName.isEmpty) {
        _errorMessage = 'Vui lòng nhập họ và tên';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Kiểm tra email đã tồn tại chưa
      bool emailExists = await _authService.checkEmailExists(email);
      if (emailExists) {
        _errorMessage = 'Email này đã được sử dụng';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _authService.signUp(
        email: email,
        password: password,
        displayName: fullName,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Đăng nhập bằng Email/Password
  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signIn(email: email, password: password);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // Bắt chính xác loại lỗi Firebase
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Đăng nhập bằng Google (Chức năng mới nâng cấp)
  Future<bool> loginWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();

      _isLoading = false;
      notifyListeners();
      return userCredential != null;
    } catch (e, stackTrace) {
      _errorMessage = _getErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signOut();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // Gửi email khôi phục mật khẩu
  Future<bool> sendPasswordReset(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Chuyển đổi mã lỗi Firebase sang tiếng Việt
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Tài khoản không tồn tại';
        case 'wrong-password':
          return 'Mật khẩu không chính xác';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'user-disabled':
          return 'Tài khoản đã bị vô hiệu hóa';
        case 'too-many-requests':
          return 'Quá nhiều lần thử. Vui lòng thử lại sau';
        case 'email-already-in-use':
          return 'Email này đã được sử dụng';
        case 'weak-password':
          return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng. Vui lòng kiểm tra lại';
        default:
          return 'Lỗi: ${error.message}'; // Hiển thị mã lỗi cụ thể từ Firebase
      }
    }
    return 'Có lỗi xảy ra: ${error.toString()}';
  }

  // Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
