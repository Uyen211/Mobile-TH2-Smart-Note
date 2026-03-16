# 🌤️ Hướng dẫn cài đặt tính năng Thời tiết (Open-Meteo)

Ứng dụng Smart Note hiện đã hỗ trợ hiển thị thời tiết khi tạo ghi chú. Tính năng này sử dụng **Open-Meteo API** - hoàn toàn miễn phí, không cần API key!

## 📋 Yêu cầu

- **Open-Meteo API**: Miễn phí, công khai (https://open-meteo.com)
- **Geolocator**: Để lấy vị trí GPS của người dùng (đã được thêm vào `pubspec.yaml`)
- **HTTP Package**: Để gửi yêu cầu API (đã được thêm vào `pubspec.yaml`)

## ✨ Ưu điểm của Open-Meteo

✅ **Hoàn toàn miễn phí** - không giới hạn yêu cầu
✅ **Không cần API key** - dùng ngay
✅ **Không cần đăng ký tài khoản**
✅ **Chính xác và nhanh**
✅ **Open source**

## 🚀 Cách cài đặt

### Bước 1: Cài đặt packages

Chạy lệnh:

```bash
flutter pub get
```

### Bước 2: Cấu hình quyền truy cập vị trí (Mobile)

#### Android (`android/app/src/main/AndroidManifest.xml`)

Thêm quyền truy cập vị trí:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS (`ios/Runner/Info.plist`)

Thêm các key sau trong `<dict>`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Ứng dụng cần truy cập vị trí để hiển thị thời tiết tại thời điểm tạo ghi chú.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Ứng dụng cần truy cập vị trí để hiển thị thời tiết tại thời điểm tạo ghi chú.</string>
```

### Bước 3: Cập nhật Dart packages

Chạy lệnh sau để cài đặt packages mới:

```bash
flutter pub get
```

## 🎯 Tính năng Hiển thị Thời tiết

Khi bạn tạo một ghi chú mới, ứng dụng sẽ:

1. **Yêu cầu quyền truy cập vị trí** từ người dùng (lần đầu)
2. **Lấy tọa độ GPS** hiện tại
3. **Gọi OpenWeatherMap API** để lấy dữ liệu thời tiết
4. **Hiển thị thông tin** trong ghi chú:
   - 🌡️ **Nhiệt độ hiện tại** và cảm giác như
   - 💧 **Độ ẩm** không khí (%)
   - 💨 **Tốc độ gió** (m/s)
   - 📍 **Thành phố và quốc gia**
   - 📝 **Mô tả trạng thái thời tiết**

## 📱 Hiển thị trong Ghi chú

Thông tin thời tiết sẽ được hiển thị trong **NoteCard** với bố cục đẹp:

```
┌─ Thời tiết: Hà Nội, VN ──────────────┐
│ Nhiệt độ: 28.5°C                      │
│ Cảm giác: 32.1°C                      │
│ Độ ẩm: 75%                            │
│ Gió: 3.2 m/s                          │
│ Tạo thanh: Partly cloudy              │
└──────────────────────────────────────┘
```

## ⚙️ Cách hoạt động

### WeatherService

File: `lib/services/weather_service.dart`

**Phương thức chính:**

- `fetchCurrentWeather()`: Lấy thời tiết từ vị trí GPS hiện tại
- `fetchWeatherByCity(String city)`: Lấy thời tiết theo tên thành phố
- `fetchWeatherByCoordinates(double lat, double lon)`: Lấy thời tiết theo tọa độ

**APIs được sử dụng:**
- **Open-Meteo Forecast API**: Lấy dữ liệu thời tiết hiện tại từ tọa độ GPS
  - Endpoint: `https://api.open-meteo.com/v1/forecast`
  - Không cần API key
  - Miễn phí, không giới hạn

- **Open-Meteo Geocoding API**: Chuyển đổi tên thành phố thành tọa độ GPS
  - Endpoint: `https://geocoding-api.open-meteo.com/v1/search`
  - Không cần API key
  - Miễn phí, không giới hạn

### Weather Model

File: `lib/models/weather_model.dart`

Lưu trữ thông tin thời tiết:

```dart
class Weather {
  final String description;      // Mô tả (Partly cloudy, Rainy, etc.)
  final String icon;             // Icon code từ API
  final double temperature;      // Độ C
  final double feelsLike;        // Cảm giác như
  final int humidity;            // 0-100%
  final int pressure;            // hPa
  final double windSpeed;        // m/s
  final String city;
  final String country;
}
```

### NoteViewModel

File: `lib/viewmodels/note_viewmodel.dart`

**Phương thức mới:**

- `addNote(Note note)`: Tự động lấy thời tiết trước khi lưu ghi chú
- `fetchCurrentWeather()`: Lấy thời tiết hiện tại (không lưu ghi chú)
- `fetchWeatherByCity(String city)`: Lấy thời tiết theo thành phố

## 🔧 Khắc phục sự cố

### Lỗi: Không lấy được vị trí

**Nguyên nhân**: Quyền truy cập vị trí bị từ chối

**Giải pháp**:
1. Kiểm tra quyền trong cài đặt ứng dụng
2. Cho phép quyền truy cập vị trí khi được hỏi
3. Khởi động lại ứng dụng

### Lỗi: Timeout khi lấy thời tiết

**Nguyên nhân**: Kết nối mạng chậm hoặc máy chủ API không phản hồi

**Giải pháp**:
1. Kiểm tra kết nối Internet
2. Đợi vài giây rồi thử lại
3. Kiểm tra trạng thái Open-Meteo tại https://status.open-meteo.com

### Lỗi: Không tìm thấy thành phố

**Nguyên nhân**: Tên thành phố không hợp lệ hoặc lỗi chính tả

**Giải pháp**:
1. Kiểm tra lại tên thành phố (ví dụ: "Hà Nội", "TP. Hồ Chí Minh")
2. Dùng tên tiếng Anh nếu không tìm thấy (ví dụ: "Hanoi")
3. Thêm quốc gia nếu cần (ví dụ: "Hanoi, Vietnam")

## 📊 Supabase Database

Thông tin thời tiết sẽ được lưu trữ trong cột `weather` của bảng `notes`:

```sql
ALTER TABLE notes ADD COLUMN weather jsonb DEFAULT NULL;
```

Dữ liệu thời tiết lưu trữ ở định dạng:

```json
{
  "description": "Partly cloudy",
  "icon": "02d",
  "temperature": 28.5,
  "feelsLike": 32.1,
  "humidity": 75,
  "pressure": 1013,
  "windSpeed": 3.2,
  "city": "Hà Nội",
  "country": "VN"
}
```

## 🌐 Hỗ trợ Web

Trên nền tảng Web, tính năng lấy vị trị GPS có thể bị hạn chế bởi trình duyệt. Trong trường hợp này, ứng dụng sẽ:

1. Hiển thị thời tiết mặc định ("Không xác định")
2. Vẫn cho phép người dùng lấy thời tiết theo tên thành phố bằng Geocoding API

Open-Meteo hoàn toàn miễn phí nên không có hạn chế API trên web.

## 📝 Ví dụ sử dụng

### Trong NoteViewModel

```dart
// Tạo ghi chú với thời tiết tự động
Future<void> addNote(Note note) async {
  // Lấy thời tiết hiện tại (không cần API key!)
  Weather? weather = await _weatherService.fetchCurrentWeather();
  
  // Tạo note với thời tiết
  final noteWithWeather = note.copyWith(weather: weather);
  
  // Lưu vào database
  await _dbService.addNote(noteWithWeather, _userId!);
}
```

### Trong EditorScreen (Optional)

```dart
// Lấy thời tiết hiện tại mà không lưu ghi chú
final weather = await noteViewModel.fetchCurrentWeather();

// Lấy thời tiết theo thành phố
final weather = await noteViewModel.fetchWeatherByCity('Hà Nội');
```

## 🎨 Tùy chỉnh

Để thay đổi giao diện hiển thị thời tiết, chỉnh sửa hàm `_buildWeatherWidget()` trong:
- `lib/views/home/widgets/note_card.dart`

## 📚 Tài liệu tham khảo

- [Open-Meteo API Documentation](https://open-meteo.com)
- [Open-Meteo Geocoding API](https://open-meteo.com/en/docs/geocoding-api)
- [Open-Meteo Weather Codes](https://open-meteo.com/en/docs)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [HTTP Package](https://pub.dev/packages/http)

## ✅ Danh sách kiểm tra

- [ ] Chạy `flutter pub get` thành công
- [ ] Đã thêm quyền truy cập vị trí cho Android
- [ ] Đã thêm quyền truy cập vị trí cho iOS
- [ ] Kiểm tra thêm ghi chú mới - thời tiết được hiển thị
- [ ] Thời tiết lưu trữ chính xác trong Supabase
- [ ] Tìm kiếm thành phố hoạt động chính xác

---

**Tạo bởi**: Smart Note Team
**Ngày**: 16/03/2026
**Phiên bản**: 1.0
