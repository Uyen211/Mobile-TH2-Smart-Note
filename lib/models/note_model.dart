import 'dart:convert';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor chính
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // copyWith: Giúp tạo bản sao mới của Object với các trường thay đổi
  // Rất hữu ích khi cập nhật State trong MVVM
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Chuyển đổi từ Map (JSON) sang Object Note [cite: 73]
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      // Parse chuỗi ISO sang DateTime
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Chuyển đổi từ Object Note sang Map (JSON) [cite: 72]
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      // Lưu DateTime dưới dạng String ISO 8601 chuẩn
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper để mã hóa danh sách ghi chú thành String để lưu vào SharedPreferences [cite: 72]
  static String encode(List<Note> notes) => json.encode(
        notes.map<Map<String, dynamic>>((note) => note.toJson()).toList(),
      );

  // Helper để giải mã String từ SharedPreferences thành danh sách ghi chú [cite: 73]
  static List<Note> decode(String notesJson) =>
      (json.decode(notesJson) as List<dynamic>)
          .map<Note>((item) => Note.fromJson(item as Map<String, dynamic>))
          .toList();
}
