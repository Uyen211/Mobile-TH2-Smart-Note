import 'dart:async';
import 'package:flutter/material.dart';
import 'package:th2_smart_note/models/note_model.dart';
import 'package:th2_smart_note/services/firestore_service.dart';

class NoteViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  StreamSubscription<List<Note>>? _notesSubscription;

  List<Note> get notes => _filteredNotes;
  bool get isEmpty => _notes.isEmpty;

  void loadNotes() {
    try {
      _notesSubscription?.cancel();
      _notesSubscription = _firestoreService.getNotes().listen(
        (notesList) {
          _notes = notesList;
          _filteredNotes = List.from(_notes);
          notifyListeners();
        },
        onError: (error) => debugPrint("Lỗi Stream: $error"),
      );
    } catch (e) {
      debugPrint("Lỗi khởi tạo loadNotes: $e");
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await _firestoreService.addNote(note);
    } catch (e) {
      debugPrint("Lỗi thêm ghi chú: $e");
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _firestoreService.updateNote(note);
    } catch (e) {
      debugPrint("Lỗi cập nhật ghi chú: $e");
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _firestoreService.deleteNote(id);
    } catch (e) {
      debugPrint("Lỗi xóa ghi chú: $e");
    }
  }

  void search(String keyword) {
    if (keyword.isEmpty) {
      _filteredNotes = List.from(_notes);
    } else {
      _filteredNotes = _notes
          .where((n) => n.title.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }
}
