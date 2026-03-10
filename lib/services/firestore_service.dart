import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:th2_smart_note/models/note_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _notesRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Chưa đăng nhập!");
    return _db.collection('users').doc(uid).collection('notes');
  }

  Stream<List<Note>> getNotes() {
    return _notesRef.orderBy('updatedAt', descending: true).snapshots().map(
        (snap) => snap.docs.map((doc) => Note.fromFirestore(doc)).toList());
  }

  Future<void> addNote(Note note) async {
    await _notesRef.add(note.toFirestore());
  }

  Future<void> updateNote(Note note) async {
    await _notesRef.doc(note.id).update(note.toFirestore());
  }

  Future<void> deleteNote(String id) async {
    await _notesRef.doc(id).delete();
  }
}
