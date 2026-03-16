import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:th2_smart_note/models/weather_model.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Weather? weather; // Thời tiết khi tạo ghi chú

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
    this.weather,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    Weather? weather,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weather: weather ?? this.weather,
    );
  }

  factory Note.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Weather? weather;
    if (data['weather'] != null) {
      weather = Weather.fromMap(data['weather'] as Map<String, dynamic>);
    }
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imagePath: data['imagePath'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      weather: weather,
    );
  }

  // Supabase: fromMap
  factory Note.fromMap(Map<String, dynamic> data) {
    Weather? weather;
    if (data['weather'] != null) {
      weather = Weather.fromMap(data['weather'] as Map<String, dynamic>);
    }
    return Note(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imagePath: data['imagePath'],
      createdAt: DateTime.parse(data['created_at'] ?? data['createdAt']),
      updatedAt: DateTime.parse(data['updated_at'] ?? data['updatedAt']),
      weather: weather,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Supabase: toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'weather': weather?.toMap(),
    };
  }
}
