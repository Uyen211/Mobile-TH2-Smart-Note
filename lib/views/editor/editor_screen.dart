import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/note_model.dart';
import '../../viewmodels/note_viewmodel.dart';
import '../../services/supabase_storage_service.dart';

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
  Note? _currentNote;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  final SupabaseStorageService _storageService = SupabaseStorageService();

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _titleController = TextEditingController(text: _currentNote?.title ?? '');
    _contentController =
        TextEditingController(text: _currentNote?.content ?? '');
    _imagePath = _currentNote?.imagePath;
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
    _debounce = Timer(const Duration(seconds: 2), () => _saveNote());
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) return;

    final finalTitle = title.isEmpty ? "Ghi chú không có tiêu đề" : title;
    final viewModel = context.read<NoteViewModel>();
    final now = DateTime.now();

    try {
      if (_currentNote == null) {
        final newNote = Note(
          id: '',
          title: finalTitle,
          content: content,
          createdAt: now,
          updatedAt: now,
          imagePath: _imagePath,
        );
        await viewModel.addNote(newNote);
        _currentNote = newNote;
      } else {
        final updatedNote = _currentNote!.copyWith(
          title: finalTitle,
          content: content,
          updatedAt: now,
          imagePath: _imagePath,
        );
        await viewModel.updateNote(updatedNote);
        _currentNote = updatedNote;
      }
    } catch (e) {
      debugPrint("Lỗi lưu Cloud: $e");
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 800, imageQuality: 70);
    if (picked != null) {
      String? imageUrl;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        imageUrl = 'data:image/png;base64,${base64Encode(bytes)}';
      } else {
        final file = File(picked.path);
        final fileName =
            'note_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
        imageUrl = await _storageService.uploadImage(file, fileName);
      }
      if (imageUrl != null) {
        setState(() => _imagePath = imageUrl);
        _onTextChanged('');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = _currentNote?.updatedAt ?? DateTime.now();
    final timeStr = DateFormat('HH:mm, dd/MM/yyyy').format(now);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) await _saveNote();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0277BD)),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined,
                  color: Color(0xFF0277BD)),
              onPressed: _pickImage,
            ),
            if (_imagePath != null)
              IconButton(
                icon: const Icon(Icons.image_not_supported_outlined,
                    color: Colors.redAccent),
                onPressed: () {
                  setState(() => _imagePath = null);
                  _saveNote();
                },
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_imagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: kIsWeb || _imagePath!.startsWith('data')
                              ? Image.network(_imagePath!,
                                  width: double.infinity, fit: BoxFit.cover)
                              : Image.file(File(_imagePath!),
                                  width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                    TextField(
                      controller: _titleController,
                      onChanged: _onTextChanged,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004C8C)),
                      decoration: const InputDecoration(
                        hintText: 'Tiêu đề',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    TextField(
                      controller: _contentController,
                      onChanged: _onTextChanged,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(
                          fontSize: 18, height: 1.5, color: Colors.black87),
                      decoration: const InputDecoration(
                        hintText: 'Bắt đầu ghi chú tại đây...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: const Color(0xFFF1F8FF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lần cuối chỉnh sửa: $timeStr',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
