class Weather {
  final String description; // ví dụ: "Partly cloudy"
  final String icon; // ví dụ: "02d"
  final double temperature; // Độ Celsius
  final double feelsLike;
  final int humidity; // 0-100%
  final int pressure; // hPa
  final double windSpeed; // m/s
  final String city;
  final String country;

  Weather({
    required this.description,
    required this.icon,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.city,
    required this.country,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['weather'][0]['main'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '01d',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      pressure: json['main']['pressure'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      city: json['name'] ?? 'Unknown',
      country: json['sys']['country'] ?? '',
    );
  }

  factory Weather.fromOpenMeteo(Map<String, dynamic> json,
      {String city = 'Current Location', String country = 'VN'}) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final temperature = (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;
    final humidity = current['relative_humidity_2m'] as int? ?? 0;
    final pressure = (current['pressure_msl'] as num?)?.toInt() ?? 0;
    final windSpeed =
        ((current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0) / 3.6;
    final weatherCode = current['weather_code'] as int? ?? 0;
    final isDay = current['is_day'] as int? ?? 1;

    final description = _getWeatherDescription(weatherCode);
    final icon = _getWeatherIcon(weatherCode, isDay == 1);

    return Weather(
      description: description,
      icon: icon,
      temperature: temperature,
      feelsLike: temperature,
      humidity: humidity,
      pressure: pressure,
      windSpeed: windSpeed,
      city: city,
      country: country,
    );
  }

  static String _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Trời quang';
      case 1 || 2:
        return 'Hầu như quang';
      case 3:
        return 'Trời nhiều mây';
      case 45 || 48:
        return 'Sương mù';
      case 51 || 53 || 55:
        return 'Mưa nhẹ';
      case 61 || 63 || 65:
        return 'Mưa';
      case 71 || 73 || 75:
        return 'Tuyết';
      case 80 || 81 || 82:
        return 'Mưa rào';
      case 85 || 86:
        return 'Tuyết rào';
      case 95 || 96 || 99:
        return 'Giông bão';
      default:
        return 'Không xác định';
    }
  }

  static String _getWeatherIcon(int code, bool isDay) {
    final dayNight = isDay ? 'd' : 'n';
    switch (code) {
      case 0:
        return '01$dayNight';
      case 1 || 2:
        return '02$dayNight';
      case 3:
        return '04$dayNight';
      case 45 || 48:
        return '50$dayNight';
      case 51 || 53 || 55 || 61 || 63 || 65 || 80 || 81 || 82:
        return '10$dayNight';
      case 71 || 73 || 75 || 85 || 86:
        return '13$dayNight';
      case 95 || 96 || 99:
        return '11$dayNight';
      default:
        return '01$dayNight';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'icon': icon,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'pressure': pressure,
      'windSpeed': windSpeed,
      'city': city,
      'country': country,
    };
  }

  factory Weather.fromMap(Map<String, dynamic> data) {
    return Weather(
      description: data['description'] ?? 'Unknown',
      icon: data['icon'] ?? '01d',
      temperature: (data['temperature'] as num).toDouble(),
      feelsLike: (data['feelsLike'] as num).toDouble(),
      humidity: data['humidity'] ?? 0,
      pressure: data['pressure'] ?? 0,
      windSpeed: (data['windSpeed'] as num).toDouble(),
      city: data['city'] ?? 'Unknown',
      country: data['country'] ?? '',
    );
  }
}
