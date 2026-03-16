import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:th2_smart_note/models/weather_model.dart';

class WeatherService {
  // Open-Meteo API - Không cần API key!
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  /// Lấy vị trí hiện tại của người dùng
  Future<Position?> _getCurrentPosition() async {
    try {
      debugPrint('📍 Đang kiểm tra quyền truy cập vị trí...');

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        debugPrint('⚠️ Quyền bị từ chối, đang yêu cầu...');
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Quyền truy cập vị trí bị từ chối vĩnh viễn.');
        return null;
      }

      debugPrint('🔍 Đang lấy vị trí GPS...');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint(
          '✅ Lấy vị trí thành công: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ Lỗi lấy vị trí: $e');
      return null;
    }
  }

  /// Lấy dữ liệu thời tiết theo tọa độ (latitude, longitude)
  Future<Weather?> fetchWeatherByCoordinates(
      double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,pressure_msl,weather_code,wind_speed_10m,is_day&timezone=auto',
      );

      debugPrint('📍 Đang lấy thời tiết từ tọa độ: $latitude, $longitude');
      debugPrint('🔗 URL: $url');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10), // Optimized timeout
        onTimeout: () {
          throw Exception('Timeout khi lấy dữ liệu thời tiết (>10s)');
        },
      );

      debugPrint('📡 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Lấy thời tiết thành công!');
        final data = jsonDecode(response.body);
        return Weather.fromOpenMeteo(data);
      } else {
        throw Exception(
            'Không thể lấy dữ liệu thời tiết: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi fetchWeatherByCoordinates: $e');
      return null;
    }
  }

  /// Lấy thời tiết theo tên thành phố
  Future<Weather?> fetchWeatherByCity(String city) async {
    try {
      // Bước 1: Geocoding - Lấy tọa độ từ tên thành phố
      final geoUrl = Uri.parse(
        '$_geocodingUrl?name=$city&count=1&language=vi&format=json',
      );

      debugPrint('🔍 Đang tìm kiếm thành phố: $city');
      debugPrint('🔗 Geocoding URL: $geoUrl');

      final geoResponse = await http.get(geoUrl).timeout(
        const Duration(seconds: 8), // Optimized timeout
        onTimeout: () {
          throw Exception('Timeout khi lấy tọa độ thành phố (>8s)');
        },
      );

      debugPrint('📡 Geocoding status: ${geoResponse.statusCode}');

      if (geoResponse.statusCode != 200) {
        debugPrint('❌ Không tìm thấy thành phố: $city');
        return null;
      }

      final geoData = jsonDecode(geoResponse.body);
      final results = geoData['results'] as List?;

      if (results == null || results.isEmpty) {
        debugPrint('❌ Không tìm thấy kết quả cho: $city');
        return null;
      }

      final location = results[0] as Map<String, dynamic>;
      final latitude = location['latitude'] as num;
      final longitude = location['longitude'] as num;
      final name = location['name'] as String? ?? city;
      final admin1 = location['admin1'] as String? ?? '';
      final countryCode = location['country_code'] as String? ?? 'VN';

      debugPrint(
          '✅ Tìm thấy: $name, $admin1 (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})');

      // Bước 2: Lấy dữ liệu thời tiết từ tọa độ
      final weatherUrl = Uri.parse(
        '$_baseUrl?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,pressure_msl,weather_code,wind_speed_10m,is_day&timezone=auto',
      );

      debugPrint('🔗 Weather URL: $weatherUrl');

      final weatherResponse = await http.get(weatherUrl).timeout(
        const Duration(seconds: 10), // Optimized timeout
        onTimeout: () {
          throw Exception('Timeout khi lấy dữ liệu thời tiết (>10s)');
        },
      );

      debugPrint('📡 Weather status: ${weatherResponse.statusCode}');

      if (weatherResponse.statusCode == 200) {
        debugPrint('✅ Lấy thời tiết cho $name thành công!');
        final weatherData = jsonDecode(weatherResponse.body);
        return Weather.fromOpenMeteo(
          weatherData,
          city: '$name${admin1.isNotEmpty ? ", $admin1" : ""}',
          country: countryCode,
        );
      } else {
        throw Exception(
            'Không thể lấy dữ liệu thời tiết: ${weatherResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi fetchWeatherByCity: $e');
      return null;
    }
  }

  /// Lấy thời tiết hiện tại dựa trên vị trí của người dùng
  Future<Weather?> fetchCurrentWeather() async {
    try {
      debugPrint('🌤️ Đang lấy thời tiết hiện tại...');

      final position = await _getCurrentPosition();

      if (position == null) {
        debugPrint(
            '⚠️ Không thể lấy vị trí hiện tại. Trả về thời tiết mặc định.');
        return _createDefaultWeather();
      }

      return await fetchWeatherByCoordinates(
          position.latitude, position.longitude);
    } catch (e) {
      debugPrint('❌ Lỗi fetchCurrentWeather: $e');
      return null;
    }
  }

  /// Tạo đối tượng Weather mặc định khi không thể lấy dữ liệu thực sự
  Weather _createDefaultWeather() {
    debugPrint('⚠️ Sử dụng thời tiết mặc định (placeholder)');
    return Weather(
      description: 'Không xác định',
      icon: '01d',
      temperature: 0.0,
      feelsLike: 0.0,
      humidity: 0,
      pressure: 0,
      windSpeed: 0.0,
      city: 'N/A',
      country: 'VN',
    );
  }
}
