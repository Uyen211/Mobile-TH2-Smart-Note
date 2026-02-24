import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Định dạng: dd/MM/yyyy HH:mm [cite: 651, 686]
    final String formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(note.updatedAt);

    return Card(
      child: InkWell(
        onTap: onTap, // Sửa lỗi "liệt" phím chạm bằng cách gán lại onTap
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF01579B)),
                maxLines: 1, // Tiêu đề tối đa 1 dòng [cite: 649]
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                maxLines: 3, // Nội dung tối đa 3 dòng [cite: 650]
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
