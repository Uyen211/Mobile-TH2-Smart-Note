import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày giờ: dd/MM/yyyy HH:mm [cite: 651, 686]
    final String formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(note.updatedAt);

    return Card(
      elevation: 3, // Đổ bóng nhẹ theo yêu cầu [cite: 647]
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap, // Sự kiện chạm để vào màn hình xem/sửa [cite: 634]
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề: In đậm, tối đa 1 dòng, hiện "..." nếu tràn [cite: 649, 746]
              Text(
                note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF01579B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Nội dung: Tối đa 3 dòng, hiện "..." nếu quá dài
              Text(
                note.content,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                maxLines: 3,
                overflow:
                    TextOverflow.ellipsis, // Đây là điểm then chốt bạn yêu cầu
              ),
              const SizedBox(height: 12),
              // Hiển thị thời gian cập nhật ở góc dưới thẻ [cite: 651]
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
