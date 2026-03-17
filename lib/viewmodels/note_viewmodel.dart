import 'dart:async';
import 'package:flutter/material.dart';
import 'package:th2_smart_note/models/note_model.dart';
import 'package:th2_smart_note/models/weather_model.dart';
import 'package:th2_smart_note/services/supabase_database_service.dart';
import 'package:th2_smart_note/services/weather_service.dart';

class NoteViewModel extends ChangeNotifier {
  final SupabaseDatabaseService _dbService = SupabaseDatabaseService();
  final WeatherService _weatherService = WeatherService();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  String? _userId;
  bool _isLoading = false;
  bool _isLoadingWeather = false; // Để theo dõi việc tải thời tiết

  List<Note> get notes => _filteredNotes;
  bool get isEmpty => _notes.isEmpty;
  bool get isLoading => _isLoading;
  bool get isLoadingWeather => _isLoadingWeather;

  void setUserId(String userId) {
    _userId = userId;
    loadNotes();
  }

  Future<void> loadNotes() async {
    if (_userId == null) {
      debugPrint('userId is null, cannot load notes');
      return;
    }
    try {
      _isLoading = true;
      notifyListeners();

      final notesList = await _dbService.getNotes(_userId!);
      _notes = notesList;
      _filteredNotes = List.from(_notes);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi loadNotes Supabase: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(Note note) async {
    if (_userId == null) {
      debugPrint('userId is null, cannot add note');
      return;
    }
    try {
      _isLoadingWeather = true;
      notifyListeners();

      debugPrint('⏳ Đang xử lý thời tiết...');

      // Kiểm tra nếu note đã có weather (từ city input) - giữ nó
      Weather? weather = note.weather;

      if (weather == null) {
        // Chỉ fetch current weather nếu note chưa có weather
        debugPrint('🌍 Note chưa có weather, fetch current location...');
        try {
          weather = await _weatherService.fetchCurrentWeather().timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              debugPrint(
                  '⏱️ Timeout lấy thời tiết (>3s), tiếp tục lưu note...');
              return null;
            },
          );
        } catch (e) {
          debugPrint('⚠️ Lỗi fetch weather: $e, tiếp tục không weather');
          weather = null;
        }
      } else {
        debugPrint(
            '✅ Note đã có weather từ city input: ${weather.city}, ${weather.country}');
      }

      if (weather != null) {
        debugPrint(
            '✅ Thời tiết: ${weather.description}, Nhiệt độ: ${weather.temperature}°C');
      } else {
        debugPrint('⚠️ Lưu note không có thời tiết');
      }

      // Tạo note mới với thời tiết (hoặc null nếu timeout)
      final noteWithWeather = note.copyWith(weather: weather);

      // Lưu vào database - LÚC NÀY ĐÃ NHANH
      debugPrint('💾 Đang lưu ghi chú...');
      await _dbService.addNote(noteWithWeather, _userId!);

      // Thêm vào local list
      _notes.insert(0, noteWithWeather);
      _filteredNotes.insert(0, noteWithWeather);

      _isLoadingWeather = false;
      debugPrint('✅ Ghi chú đã lưu!');
      notifyListeners();

      // LÀM BACKGROUND: Nếu chưa có weather, thử fetch lại ở background
      if (weather == null) {
        debugPrint('🔄 Đang fetch weather ở background...');
        _fetchWeatherInBackground(noteWithWeather.id);
      }
    } catch (e) {
      debugPrint("❌ Lỗi thêm ghi chú Supabase: $e");
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  /// Fetch weather ở background và update note
  void _fetchWeatherInBackground(String noteId) {
    // Chạy async mà không chặn main thread
    _weatherService.fetchCurrentWeather().then((weather) {
      if (weather != null) {
        debugPrint(
            '✅ Background weather fetch thành công: ${weather.description}');

        // Tìm note và update weather
        final noteIndex = _notes.indexWhere((n) => n.id == noteId);
        if (noteIndex != -1) {
          _notes[noteIndex] = _notes[noteIndex].copyWith(weather: weather);
          final filteredIndex =
              _filteredNotes.indexWhere((n) => n.id == noteId);
          if (filteredIndex != -1) {
            _filteredNotes[filteredIndex] =
                _filteredNotes[filteredIndex].copyWith(weather: weather);
          }
          notifyListeners();

          // Update database
          _dbService.updateNote(_notes[noteIndex]).then((_) {
            debugPrint('✅ Note đã cập nhật weather ở database');
          }).catchError((e) {
            debugPrint('❌ Lỗi update weather: $e');
          });
        }
      }
    }).catchError((e) {
      debugPrint('⚠️ Background weather fetch thất bại: $e');
    });
  }

  Future<void> updateNote(Note note) async {
    try {
      await _dbService.updateNote(note);
      // Cập nhật local list
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
        final filteredIndex = _filteredNotes.indexWhere((n) => n.id == note.id);
        if (filteredIndex != -1) {
          _filteredNotes[filteredIndex] = note;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi cập nhật ghi chú Supabase: $e");
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _dbService.deleteNote(id);
      // Xóa từ local list
      _notes.removeWhere((n) => n.id == id);
      _filteredNotes.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Lỗi xóa ghi chú Supabase: $e");
      notifyListeners();
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

  /// Lấy thời tiết hiện tại
  Future<Weather?> fetchCurrentWeather() async {
    try {
      debugPrint('🌤️ Fetching current weather...');
      final weather = await _weatherService.fetchCurrentWeather();
      if (weather != null) {
        debugPrint('✅ Fetched: ${weather.description}');
      }
      return weather;
    } catch (e) {
      debugPrint("❌ Lỗi lấy thời tiết: $e");
      return null;
    }
  }

  /// Lấy thời tiết theo tên thành phố
  Future<Weather?> fetchWeatherByCity(String city) async {
    try {
      debugPrint('🌤️ Fetching weather for city: $city');
      final weather = await _weatherService.fetchWeatherByCity(city);
      if (weather != null) {
        debugPrint('✅ Fetched: ${weather.city}, ${weather.description}');
      }
      return weather;
    } catch (e) {
      debugPrint("❌ Lỗi lấy thời tiết theo thành phố: $e");
      return null;
    }
  }
}
