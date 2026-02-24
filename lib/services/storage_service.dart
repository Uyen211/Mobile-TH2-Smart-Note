import '../core/utils/json_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class StorageService {
  // Khóa duy nhất để định danh dữ liệu ghi chú trong bộ nhớ máy
  static const String _notesKey = 'smart_notes_storage';

  /// Tải danh sách ghi chú từ bộ nhớ cục bộ [cite: 7, 73]
  Future<List<Note>> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notesJson = prefs.getString(_notesKey);

      // Nếu không có dữ liệu (lần đầu mở app), trả về danh sách rỗng [cite: 67, 142]
      if (notesJson == null || notesJson.isEmpty) {
        return [];
      }

      // Giải mã chuỗi JSON thành List<dynamic> sau đó map sang List<Note]
      final decoded = JsonHelper.safeDecode<List<dynamic>>(
        notesJson,
        (d) => d as List<dynamic>,
      );
      if (decoded == null) return [];
      return decoded
          .map((item) => Note.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Bọc try-catch để tránh crash ứng dụng nếu chuỗi JSON bị hỏng [cite: 140, 142]
      debugPrint('Lỗi khi load dữ liệu: $e');
      return [];
    }
  }

  /// Lưu toàn bộ danh sách ghi chú xuống thiết bị (Ghi đè)
  Future<bool> saveNotes(List<Note> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Sử dụng helper ở model để mã hóa danh sách Note
      final String encodedData = Note.encode(notes);
      return await prefs.setString(_notesKey, encodedData);
    } catch (e) {
      debugPrint('Lỗi khi lưu dữ liệu: $e');
      return false;
    }
  }

  /// Xóa toàn bộ dữ liệu ghi chú trong bộ nhớ [cite: 43]
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_notesKey);
    } catch (e) {
      debugPrint('Lỗi khi xóa dữ liệu: $e');
      return false;
    }
  }
}

// Helper function để in log nhanh trong quá trình dev (tùy chọn)
void debugPrint(String message) {
  print('[StorageService] $message');
}
