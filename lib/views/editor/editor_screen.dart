import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../viewmodels/note_viewmodel.dart';

class EditorScreen extends StatefulWidget {
  final Note? note;
  const EditorScreen({super.key, this.note});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Timer? _debounce;
  Note? _currentNote; // Vá lỗi Duplicate bằng cách theo dõi note hiện tại

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _titleController = TextEditingController(text: _currentNote?.title ?? '');
    _contentController =
        TextEditingController(text: _currentNote?.content ?? '');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 2),
        () => _saveNote()); // Debounce 2s để vượt bài test Kill App
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty)
      return; // Không lưu nếu rỗng [cite: 755]

    final finalTitle = title.isEmpty ? "Ghi chú không có tiêu đề" : title;
    final viewModel = context.read<NoteViewModel>();
    final now = DateTime.now();

    if (_currentNote == null) {
      final newNote = Note(
        id: now.millisecondsSinceEpoch.toString(),
        title: finalTitle,
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      await viewModel.addNote(newNote);
      _currentNote =
          newNote; // Cập nhật tham chiếu ngay lập tức để tránh Duplicate
    } else {
      final updatedNote = _currentNote!
          .copyWith(title: finalTitle, content: content, updatedAt: now);
      await viewModel.updateNote(updatedNote);
      _currentNote = updatedNote;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) await _saveNote(); // Auto-save khi Back [cite: 659, 750]
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.blue),
            elevation: 0),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                onChanged: _onTextChanged,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
                decoration: const InputDecoration(
                    hintText: 'Tiêu đề...',
                    border: InputBorder.none), // Ẩn viền [cite: 655]
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  onChanged: _onTextChanged,
                  maxLines: null, // Nhập liệu đa dòng [cite: 656, 743]
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                      hintText: 'Bắt đầu nhập nội dung...',
                      border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
