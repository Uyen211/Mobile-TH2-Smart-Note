import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Lấy user hiện tại
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream để theo dõi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Đăng ký tài khoản mới bằng Email/Password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cập nhật display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Đăng nhập bằng Email/Password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint("AuthService SignIn Error: $e");
      rethrow;
    }
  }

  // Đăng nhập bằng tài khoản Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Kích hoạt luồng đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Lấy chi tiết xác thực
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Tạo credential cho Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase
      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("AuthService SignIn Error: $e");
      rethrow;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Đăng xuất Google
      await _firebaseAuth.signOut(); // Đăng xuất Firebase
    } catch (e) {
      rethrow;
    }
  }

  // Kiểm tra email đã tồn tại
  Future<bool> checkEmailExists(String email) async {
    try {
      // Firebase sẽ tự động throw lỗi nếu email không hợp lệ hoặc không tồn tại
      // Đây là cách kiểm tra nhanh thông qua việc thử đăng nhập với pass giả
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: 'check-email-dummy-password',
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return false;
      }
      return true; // Nếu lỗi mật khẩu sai nghĩa là email có tồn tại
    } catch (e) {
      return false;
    }
  }

  // Gửi email khôi phục mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
