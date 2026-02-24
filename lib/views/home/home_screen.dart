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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NoteViewModel>()
          .loadNotes(); // Tải dữ liệu khi khởi động [cite: 629]
    });
  }

  Future<void> _navigateToEditor(BuildContext context, [Note? note]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditorScreen(note: note)),
    );
    if (mounted)
      await context
          .read<NoteViewModel>()
          .loadNotes(); // Auto-refresh [cite: 638, 660]
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoteViewModel>();

    return Scaffold(
      appBar: AppBar(
        // Định danh bắt buộc: Smart Note - [Họ tên] - [MSSV] [cite: 641, 738]
        title: const Text('Smart Note - Nguyễn Hà Phương Uyên - 2351170632'),
      ),
      body: Column(
        children: [
          // Search Bar bo góc, xanh nhạt [cite: 642]
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) =>
                  viewModel.search(value), // Real-time search [cite: 643]
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(context),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildMainContent(NoteViewModel viewModel) {
    if (viewModel.isEmpty || viewModel.notes.isEmpty) {
      return Center(
        child: Opacity(
          opacity: 0.3, // Hình ảnh minh họa mờ [cite: 652, 740]
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/empty_state.png', width: 200),
              const SizedBox(height: 10),
              const Text("Bạn chưa có ghi chú nào, hãy tạo mới nhé!",
                  style: TextStyle(fontSize: 16)),
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
        crossAxisCount: 2, // Lưới 2 cột [cite: 645, 745]
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: viewModel.notes.length,
        itemBuilder: (context, index) {
          final note = viewModel.notes[index];
          return Dismissible(
            key: Key(note.id),
            direction: DismissDirection.horizontal,
            background: Container(
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(15)),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete,
                  color: Colors.white), // Nền đỏ, icon thùng rác [cite: 663]
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                // Hộp thoại xác nhận bắt buộc [cite: 664]
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận xóa'),
                  content: const Text(
                      'Bạn có chắc chắn muốn xóa ghi chú này không?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('OK',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
            onDismissed: (_) => viewModel.deleteNote(note.id),
            child: NoteCard(
                note: note, onTap: () => _navigateToEditor(context, note)),
          );
        },
      ),
    );
  }
}
