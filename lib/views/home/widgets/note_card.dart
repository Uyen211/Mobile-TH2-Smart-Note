import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Cần thiết để kiểm tra nền tảng Web
import '../../../models/note_model.dart'; // Sử dụng Package Import để tránh lỗi

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày giờ: dd/MM/yyyy HH:mm
    final String formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(note.updatedAt);

    return Card(
      elevation: 3, // Đổ bóng nhẹ theo yêu cầu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Bo góc 15px cho thẻ ghi chú
      ),
      child: InkWell(
        onTap: onTap, // Sự kiện chạm để vào màn hình soạn thảo
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Xử lý hiển thị ảnh linh hoạt: Image.network cho Web/Base64 và Image.file cho Mobile
              if (note.imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageWidget(note.imagePath!),
                ),
                const SizedBox(height: 10),
              ],

              // Tiêu đề: In đậm, tối đa 1 dòng, hiện "..." nếu tràn
              Text(
                note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF01579B), // Màu xanh biển đậm chuyên nghiệp
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
                    TextOverflow.ellipsis, // Điểm then chốt để giữ bố cục lưới
              ),
              const SizedBox(height: 12),

              // Hiển thị thời gian cập nhật ở góc dưới bên phải
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

  // Hàm phụ trợ để xử lý hiển thị ảnh dựa trên nền tảng và loại dữ liệu
  Widget _buildImageWidget(String path) {
    // Nếu là Web hoặc chuỗi Base64 (bắt đầu bằng data:) thì dùng Image.network
    if (kIsWeb || path.startsWith('data:') || path.startsWith('http')) {
      return Image.network(
        path,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      // Nếu là Mobile thì dùng Image.file (yêu cầu dart:io)
      return Image.file(
        File(path),
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
  }
}
