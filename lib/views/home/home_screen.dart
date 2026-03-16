// home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/note_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/note_model.dart';
import '../editor/editor_screen.dart';
import 'widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      final noteVM = context.read<NoteViewModel>();
      final user = authVM.currentUser;

      if (user != null) {
        // QUAN TRỌNG: Supabase sử dụng .id thay vì .uid như Firebase
        noteVM.setUserId(user.id);
      }
    });
  }

  // Điều hướng sang Editor. Nhờ cơ chế Stream, chúng ta không cần refresh thủ công nữa.
  Future<void> _navigateToEditor(BuildContext context, [Note? note]) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditorScreen(note: note),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Theo dõi ViewModel để cập nhật UI khi danh sách ghi chú thay đổi
    final viewModel = context.watch<NoteViewModel>();

    return Scaffold(
      appBar: AppBar(
        // Giữ nguyên định danh cá nhân theo yêu cầu
        title: const Text('Smart Note - Nguyễn Hà Phương Uyên - 2351170632'),
        centerTitle: true,
        elevation: 2,
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, authVM, _) {
              return PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'logout') {
                    _showLogoutConfirm(context, authVM);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Đăng xuất'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) =>
                  viewModel.search(value), // Lọc real-time cục bộ
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tiêu đề...',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: const Color.fromRGBO(33, 150, 243, 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildMainContent(viewModel)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(context), // Mở màn hình tạo mới
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildMainContent(NoteViewModel viewModel) {
    // Hiển thị trạng thái trống nếu Supabase chưa có dữ liệu
    // Lưu ý: Đảm bảo NoteViewModel của bạn có getter `isEmpty`
    if (viewModel.notes.isEmpty) {
      return Center(
        child: Opacity(
          opacity: 0.3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/empty_state.png', width: 200),
              const SizedBox(height: 10),
              const Text(
                "Bạn chưa có ghi chú nào, hãy tạo mới nhé!",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    return _buildNoteGrid(viewModel);
  }

  Widget _buildNoteGrid(NoteViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MasonryGridView.count(
        crossAxisCount: 2, // Lưới 2 cột theo yêu cầu
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: viewModel.notes.length,
        itemBuilder: (context, index) {
          final note = viewModel.notes[index];
          return Dismissible(
            key: Key(note.id), // ID từ Supabase
            direction: DismissDirection.horizontal,
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận xóa'),
                  content: const Text(
                      'Bạn có chắc chắn muốn xóa ghi chú này không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child:
                          const Text('OK', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            // Gọi hàm xóa trên Supabase
            onDismissed: (_) => viewModel.deleteNote(note.id),
            child: NoteCard(
              note: note,
              onTap: () => _navigateToEditor(context, note),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authVM.logout(); // Xử lý đăng xuất
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
