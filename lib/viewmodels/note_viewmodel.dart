import 'dart:async';
import 'package:flutter/material.dart';
import 'package:th2_smart_note/models/note_model.dart';
import 'package:th2_smart_note/services/supabase_database_service.dart';

class NoteViewModel extends ChangeNotifier {
  final SupabaseDatabaseService _dbService = SupabaseDatabaseService();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String? _userId;

  List<Note> get notes => _filteredNotes;
  bool get isEmpty => _notes.isEmpty;

  void setUserId(String userId) {
    _userId = userId;
    loadNotes();
  }

  Future<void> loadNotes() async {
    if (_userId == null) return;
    try {
      final notesList = await _dbService.getNotes(_userId!);
      _notes = notesList;
      _filteredNotes = List.from(_notes);
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi loadNotes Supabase: $e");
    }
  }

  Future<void> addNote(Note note) async {
    if (_userId == null) return;
    try {
      await _dbService.addNote(note, _userId!);
      await loadNotes();
    } catch (e) {
      debugPrint("Lỗi thêm ghi chú Supabase: $e");
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _dbService.updateNote(note);
      await loadNotes();
    } catch (e) {
      debugPrint("Lỗi cập nhật ghi chú Supabase: $e");
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _dbService.deleteNote(id);
      await loadNotes();
    } catch (e) {
      debugPrint("Lỗi xóa ghi chú Supabase: $e");
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
}
