import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/note_model.dart';
import '../../models/weather_model.dart';
import '../../viewmodels/note_viewmodel.dart';
import '../../services/supabase_storage_service.dart';

class EditorScreen extends StatefulWidget {
  final Note? note;
  const EditorScreen({super.key, this.note});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _cityController;
  Timer? _debounce;
  Note? _currentNote;
  String? _imagePath;
  bool _isLoadingWeather = false;
  final ImagePicker _picker = ImagePicker();
  final SupabaseStorageService _storageService = SupabaseStorageService();

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _titleController = TextEditingController(text: _currentNote?.title ?? '');
    _contentController =
        TextEditingController(text: _currentNote?.content ?? '');
    _cityController = TextEditingController();
    _imagePath = _currentNote?.imagePath;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 2), () => _saveNote());
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) return;

    final finalTitle = title.isEmpty ? "Ghi chú không có tiêu đề" : title;
    final viewModel = context.read<NoteViewModel>();
    final now = DateTime.now();

    try {
      if (_currentNote == null) {
        final newNote = Note(
          id: const Uuid().v4(),
          title: finalTitle,
          content: content,
          createdAt: now,
          updatedAt: now,
          imagePath: _imagePath,
        );
        await viewModel.addNote(newNote);
        _currentNote = newNote;
      } else {
        final updatedNote = _currentNote!.copyWith(
          title: finalTitle,
          content: content,
          updatedAt: now,
          imagePath: _imagePath,
        );
        await viewModel.updateNote(updatedNote);
        _currentNote = updatedNote;
      }
    } catch (e) {
      debugPrint("Lỗi lưu Cloud: $e");
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 800, imageQuality: 70);
    if (picked != null) {
      String? imageUrl;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        imageUrl = 'data:image/png;base64,${base64Encode(bytes)}';
      } else {
        final file = File(picked.path);
        final fileName =
            'note_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
        imageUrl = await _storageService.uploadImage(file, fileName);
      }
      if (imageUrl != null) {
        setState(() => _imagePath = imageUrl);
        _onTextChanged('');
      }
    }
  }

  Future<void> _fetchWeatherByCity() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên thành phố')),
      );
      return;
    }

    setState(() => _isLoadingWeather = true);

    try {
      final viewModel = context.read<NoteViewModel>();
      final weather = await viewModel.fetchWeatherByCity(city);
      if (weather != null) {
        setState(() {
          _currentNote = _currentNote?.copyWith(weather: weather) ??
              Note(
                id: const Uuid().v4(),
                title: 'Ghi chú',
                content: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                weather: weather,
              );
          _isLoadingWeather = false;
          _cityController.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Lấy thời tiết: ${weather.city}')),
          );
        }
      } else {
        setState(() => _isLoadingWeather = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Không tìm được thành phố')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoadingWeather = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = _currentNote?.updatedAt ?? DateTime.now();
    final timeStr = DateFormat('HH:mm, dd/MM/yyyy').format(now);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) await _saveNote();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0277BD)),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined,
                  color: Color(0xFF0277BD)),
              onPressed: _pickImage,
            ),
            if (_imagePath != null)
              IconButton(
                icon: const Icon(Icons.image_not_supported_outlined,
                    color: Colors.redAccent),
                onPressed: () {
                  setState(() => _imagePath = null);
                  _saveNote();
                },
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_imagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: kIsWeb || _imagePath!.startsWith('data')
                              ? Image.network(_imagePath!,
                                  width: double.infinity, fit: BoxFit.cover)
                              : Image.file(File(_imagePath!),
                                  width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                    // Input thành phố để fetch thời tiết
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                hintText: 'Nhập tên thành phố...',
                                hintStyle: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                                prefixIcon:
                                    const Icon(Icons.location_on, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed:
                                _isLoadingWeather ? null : _fetchWeatherByCity,
                            icon: _isLoadingWeather
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.cloud_download),
                            label: Text(_isLoadingWeather ? '' : 'Lấy TT'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Hiển thị thời tiết (nếu có)
                    if (_currentNote?.weather != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildWeatherWidget(_currentNote!.weather!),
                      ),
                    TextField(
                      controller: _titleController,
                      onChanged: _onTextChanged,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004C8C)),
                      decoration: const InputDecoration(
                        hintText: 'Tiêu đề',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    TextField(
                      controller: _contentController,
                      onChanged: _onTextChanged,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(
                          fontSize: 18, height: 1.5, color: Colors.black87),
                      decoration: const InputDecoration(
                        hintText: 'Bắt đầu ghi chú tại đây...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: const Color(0xFFF1F8FF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lần cuối chỉnh sửa: $timeStr',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị thông tin thời tiết
  Widget _buildWeatherWidget(Weather weather) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.cloud, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Thời tiết: ${weather.city}, ${weather.country}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.blue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Chi tiết thời tiết
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nhiệt độ
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.thermostat, size: 18, color: Colors.red),
                    const SizedBox(height: 4),
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Cảm: ${weather.feelsLike.toStringAsFixed(1)}°C',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Độ ẩm
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.opacity, size: 18, color: Colors.cyan),
                    const SizedBox(height: 4),
                    Text(
                      '${weather.humidity}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Độ ẩm',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Gió
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.air, size: 18, color: Colors.teal),
                    const SizedBox(height: 4),
                    Text(
                      '${weather.windSpeed.toStringAsFixed(1)}m/s',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Gió',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Mô tả
          Row(
            children: [
              const Icon(Icons.description, size: 14, color: Colors.orange),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  weather.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
