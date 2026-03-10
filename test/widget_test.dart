import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:th2_smart_note/main.dart';
import 'package:th2_smart_note/viewmodels/note_viewmodel.dart';
import 'package:th2_smart_note/viewmodels/auth_viewmodel.dart';

// Giả lập NoteViewModel để không gọi vào StorageService thật
class TestNoteViewModel extends NoteViewModel {
  @override
  Future<void> loadNotes() async {} // Không làm gì khi load

  @override
  bool get isEmpty => false; // Giả định có dữ liệu để hiện Grid
}

// Giả lập AuthViewModel để vượt qua màn hình Login
class TestAuthViewModel extends AuthViewModel {
  @override
  bool get isLoggedIn => true; // Luôn trả về true để vào thẳng HomeScreen

  @override
  String? get errorMessage => null;
}

void main() {
  testWidgets('App builds and shows home title and FAB',
      (WidgetTester tester) async {
    // Khởi tạo các mock viewmodel
    final mockNoteVM = TestNoteViewModel();
    final mockAuthVM = TestAuthViewModel();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // Cần cung cấp cả 2 Provider như trong main.dart [cite: 3104-3106]
          ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthVM),
          ChangeNotifierProvider<NoteViewModel>.value(value: mockNoteVM),
        ],
        child: const SmartNoteApp(),
      ),
    );

    // Chờ các animation và microtasks hoàn tất
    await tester.pumpAndSettle();

    // 1. Kiểm tra tiêu đề có chứa "Smart Note" [cite: 2883]
    expect(find.textContaining('Smart Note'), findsOneWidget);

    // 2. Kiểm tra có sự xuất hiện của nút thêm mới (FAB) [cite: 2928-2930]
    expect(find.byIcon(Icons.add), findsOneWidget);

    // 3. Kiểm tra xem có hiển thị đúng MSSV của bạn không
    expect(find.textContaining('2351170632'), findsOneWidget);
  });
}
