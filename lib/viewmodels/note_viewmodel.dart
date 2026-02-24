import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/storage_service.dart';

class NoteViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  // Danh sách gốc (Data Source)
  List<Note> _notes = [];

  // Danh sách hiển thị sau khi lọc (UI State)
  //  Tránh can thiệp vào danh sách gốc khi tìm kiếm
  List<Note> _filteredNotes = [];

  // Getters cho UI
  List<Note> get notes => _filteredNotes;
  bool get isEmpty => _notes.isEmpty;

  /// Tải dữ liệu từ thiết bị khi khởi động App
  /// [cite: 7, 54] Bước 1: Khởi động App -> Đọc dữ liệu từ thiết bị
  Future<void> loadNotes() async {
    _notes = await _storageService.loadNotes();
    _filteredNotes = List.from(_notes);
    notifyListeners();
  }

  /// Thêm ghi chú mới
  Future<void> addNote(Note note) async {
    _notes.insert(0, note); // Thêm vào đầu danh sách
    await _saveAndRefresh();
  }

  /// Cập nhật ghi chú cũ
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((item) => item.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      await _saveAndRefresh();
    }
  }

  /// Xóa ghi chú theo ID
  /// [cite: 43, 55] Thực hiện sau khi người dùng xác nhận Dialog
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await _saveAndRefresh();
  }

  /// Tìm kiếm theo Tiêu đề (Real-time)
  /// [cite: 14, 21] Tự động lọc kết quả theo Tiêu đề ghi chú
  void search(String keyword) {
    if (keyword.isEmpty) {
      _filteredNotes = List.from(_notes);
    } else {
      _filteredNotes = _notes
          .where((note) =>
              note.title.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners(); // Cập nhật UI tạm thời
  }

  /// Hàm hỗ trợ: Lưu xuống máy và đồng bộ danh sách hiển thị
  /// [cite: 37, 61] Đảm bảo gọi lệnh lưu ngay khi có thay đổi
  Future<void> _saveAndRefresh() async {
    // Luôn lưu danh sách gốc (_notes)
    await _storageService.saveNotes(_notes);

    // Cập nhật lại danh sách hiển thị (để giữ nguyên kết quả tìm kiếm nếu đang search)
    // Hoặc đơn giản là reset lại danh sách nếu không search
    _filteredNotes = List.from(_notes);

    notifyListeners();
  }
}
