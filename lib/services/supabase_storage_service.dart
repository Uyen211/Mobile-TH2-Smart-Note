import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final String bucket = 'note-images';

  // Upload ảnh
  Future<String?> uploadImage(File file, String fileName) async {
    final response = await _client.storage.from(bucket).upload(
          fileName,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
    if (response.isNotEmpty) {
      return _client.storage.from(bucket).getPublicUrl(fileName);
    }
    return null;
  }

  // Lấy URL ảnh
  String getImageUrl(String fileName) {
    return _client.storage.from(bucket).getPublicUrl(fileName);
  }

  // Xóa ảnh
  Future<void> deleteImage(String fileName) async {
    await _client.storage.from(bucket).remove([fileName]);
  }
}
