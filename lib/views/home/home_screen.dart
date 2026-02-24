import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/note_viewmodel.dart';
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
    // Bước 1: Khởi động App -> Đọc dữ liệu từ thiết bị [cite: 629]
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteViewModel>().loadNotes();
    });
  }

  // Luồng Navigation: Đợi người dùng quay lại và tự động cập nhật dữ liệu [cite: 638, 735]
  Future<void> _navigateToEditor(BuildContext context, [Note? note]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditorScreen(note: note)),
    );
    // Sau khi pop, thực hiện refresh để hiển thị dữ liệu mới nhất [cite: 660, 735]
    if (mounted) {
      await context.read<NoteViewModel>().loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoteViewModel>();

    return Scaffold(
      appBar: AppBar(
        // Định danh bắt buộc: Smart Note - [Họ tên] - [MSSV]
        title: const Text('Smart Note - Nguyễn Hà Phương Uyên - 2351170632'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm: Bo góc tròn, lọc kết quả real-time [cite: 642, 643]
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => viewModel.search(value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tiêu đề...',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.blue.withOpacity(0.05),
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
      // Nút Thêm mới (FAB) [cite: 653]
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(context),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildMainContent(NoteViewModel viewModel) {
    // Hiển thị trạng thái trống nếu không có dữ liệu [cite: 630, 652]
    if (viewModel.isEmpty || viewModel.notes.isEmpty) {
      return Center(
        child: Opacity(
          opacity: 0.3, // Hình ảnh minh họa mờ [cite: 740]
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
        crossAxisCount: 2, // Lưới 2 cột bắt buộc [cite: 645, 745]
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: viewModel.notes.length,
        itemBuilder: (context, index) {
          final note = viewModel.notes[index];
          return Dismissible(
            key: Key(note.id),
            direction: DismissDirection.horizontal,
            // Nền đỏ và icon thùng rác khi vuốt để xóa [cite: 663]
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            // Hộp thoại xác nhận trước khi thực hiện xóa [cite: 664, 665]
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
}
