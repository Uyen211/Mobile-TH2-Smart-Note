import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note_model.dart';

class SupabaseDatabaseService {
  SupabaseClient get _client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw Exception('Supabase chưa được khởi tạo: $e');
    }
  }

  final String table = 'notes';

  // Lấy danh sách ghi chú
  Future<List<Note>> getNotes(String userId) async {
    final response = await _client
        .from(table)
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    return (response as List)
        .map((data) => Note.fromMap(data as Map<String, dynamic>))
        .toList();
  }

  // Thêm ghi chú
  Future<void> addNote(Note note, String userId) async {
    final data = note.toMap();
    data['user_id'] = userId;
    await _client.from(table).insert(data);
  }

  // Cập nhật ghi chú
  Future<void> updateNote(Note note) async {
    await _client.from(table).update(note.toMap()).eq('id', note.id);
  }

  // Xóa ghi chú
  Future<void> deleteNote(String noteId) async {
    await _client.from(table).delete().eq('id', noteId);
  }
}
