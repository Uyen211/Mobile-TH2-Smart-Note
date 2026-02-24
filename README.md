# Smart Note (th2_smart_note)

## Giới thiệu

**Tên dự án:** Smart Note (th2_smart_note)

**Họ tên:** Nguyễn Hà Phương Uyên
**MSSV:** 2351170632
**Môn học:** Lập trình Ứng dụng Di động

**Mô tả ngắn:** Ứng dụng ghi chú nhẹ, hỗ trợ tạo, sửa, xóa, tìm kiếm và lưu trữ offline. Dự án sử dụng kiến trúc MVVM với `provider` để quản lý trạng thái và `shared_preferences` để lưu dữ liệu cục bộ dưới dạng JSON.

**Mục tiêu:** Bài tập môn lập trình ứng dụng di động — cung cấp một ứng dụng ghi chú đơn giản, ổn định, có auto-save, khả năng hoạt động offline và trải nghiệm UX thân thiện.

---

## Tính năng chính

- **CRUD (Create / Read / Update / Delete)**: Tạo, đọc, sửa và xóa ghi chú.
- **Tìm kiếm Real-time**: Tìm theo tiêu đề (filter trên `NoteViewModel`).
- **Auto-save (Debounce)**: Tự động lưu khi người dùng nhập, debounce 2 giây trong `EditorScreen`.
- **Xác nhận xóa + Swipe delete**: Xóa bằng thao tác vuốt (`Dismissible`) kèm hộp thoại xác nhận.
- **Offline persistence**: Lưu toàn bộ danh sách ghi chú bằng `SharedPreferences` (JSON).
- **Masonry layout**: Hiển thị dạng lưới Masonry 2 cột (giao diện giống Pinterest) bằng `flutter_staggered_grid_view`.
- **Kill App test support**: Debounce + save on pop/back để giảm rủi ro mất dữ liệu khi ứng dụng bị kill.

---

## Công nghệ & thư viện

- **Dart SDK:** >=3.0.0 <4.0.0 (null-safety)
- **Flutter:** tương thích với Flutter ổn định hiện có (yêu cầu Flutter với Dart 3+).

Các package chính (theo `pubspec.yaml`):

- `provider` — Quản lý trạng thái theo pattern MVVM bằng `ChangeNotifier` (`NoteViewModel`).
- `shared_preferences` — Lưu/đọc dữ liệu cục bộ (dùng để persist danh sách ghi chú dưới dạng JSON).
- `flutter_staggered_grid_view` — Hiển thị lưới Masonry 2 cột cho danh sách ghi chú.
- `intl` — Định dạng ngày/giờ (`DateFormat`) để hiển thị `updatedAt`.
- `cupertino_icons` — Icon mặc định.

---

## Kiến trúc dự án

Pattern chính: **MVVM** (Model — View — ViewModel) kết hợp `provider` + `ChangeNotifier`.

Thư mục chính (cây rút gọn):

```
lib/
├─ main.dart
├─ core/
│  ├─ theme.dart
│  └─ utils/
│     └─ json_helper.dart
├─ models/
│  └─ note_model.dart
├─ services/
│  └─ storage_service.dart
├─ viewmodels/
│  └─ note_viewmodel.dart
└─ views/
	├─ home/
	│  ├─ home_screen.dart
	│  └─ widgets/note_card.dart
	└─ editor/
		└─ editor_screen.dart
```

Vai trò từng phần:
- `lib/models/note_model.dart`: Định nghĩa `Note`, conversion `toJson`/`fromJson`, helper encode/decode.
- `lib/services/storage_service.dart`: Trừu tượng hoá I/O cục bộ (SharedPreferences) — `loadNotes`, `saveNotes`, `clearAll`.
- `lib/viewmodels/note_viewmodel.dart`: `ChangeNotifier` chịu trách nhiệm quản lý dữ liệu ứng dụng, lọc tìm kiếm và đồng bộ với `StorageService`.
- `lib/views/*`: Giao diện người dùng. `HomeScreen` hiển thị lưới ghi chú; `EditorScreen` xử lý tạo/sửa và auto-save.
- `lib/core/*`: Theme và utility (ví dụ `JsonHelper` để decode an toàn).

Lưu ý: `main.dart` khởi tạo `MultiProvider` và cung cấp `NoteViewModel` cho toàn app.

---

## Luồng hoạt động của ứng dụng

1. App start
	- `main.dart` khởi tạo `MultiProvider` với `NoteViewModel`.
	- `HomeScreen` gọi `context.read<NoteViewModel>().loadNotes()` trong `initState` (sau frame đầu tiên).

2. Load data
	- `NoteViewModel.loadNotes()` gọi `StorageService.loadNotes()`.
	- `StorageService` đọc chuỗi JSON từ `SharedPreferences` (key: `smart_notes_storage`) và decode thành `List<Note>`.

3. Hiển thị
	- Danh sách sử dụng `_filteredNotes` (view model) để có thể giữ kết quả tìm kiếm.
	- Giao diện chính dùng `MasonryGridView` (2 cột) — file: [lib/views/home/home_screen.dart](lib/views/home/home_screen.dart).

4. Thêm / Chỉnh sửa
	- Khi nhấn `FloatingActionButton` hoặc chạm `NoteCard`, điều hướng tới [lib/views/editor/editor_screen.dart](lib/views/editor/editor_screen.dart).
	- `EditorScreen` sử dụng `TextEditingController` cho tiêu đề và nội dung.
	- `onChanged` gọi `_onTextChanged`, dùng `Timer` debounce 2s rồi gọi `_saveNote()`.
	- `_saveNote()` tạo `Note` mới (id dựa trên `DateTime.millisecondsSinceEpoch`) hoặc cập nhật `Note` hiện tại, sau đó gọi `NoteViewModel.addNote` / `updateNote`.
	- `NoteViewModel` lưu danh sách qua `StorageService.saveNotes()` và cập nhật `_filteredNotes` rồi `notifyListeners()`.

5. Auto-save & Kill-App resilience
	- Debounce 2s trong `EditorScreen` giảm số lần ghi and giúp dữ liệu kịp lưu khi app bị kill.
	- `EditorScreen` còn gọi `_saveNote()` khi thoát màn hình (back/pop) để đảm bảo lưu trước khi rời.
	- Lưu ý: `EditorScreen` sử dụng `PopScope` để can thiệp hành vi pop; tuy nhiên implementation của `PopScope` không rõ ràng trong repository (không tìm thấy class `PopScope`), nên chức năng pop-based save dựa trên đoạn code hiện tại — nếu `PopScope` không tồn tại, hành vi cần thay `WillPopScope` hoặc bổ sung widget tương ứng.

6. Xóa
	- Xóa bằng `Dismissible` (vuốt) trong `HomeScreen`. Trước khi xóa, hiển thị `AlertDialog` xác nhận; sau đó `NoteViewModel.deleteNote(id)` sẽ cập nhật danh sách và lưu.

7. Tìm kiếm
	- `HomeScreen` có `TextField` tìm kiếm; mỗi lần thay đổi gọi `NoteViewModel.search(keyword)` để cập nhật `_filteredNotes` và UI.

---

## Cách cài đặt & chạy

Yêu cầu môi trường (tối thiểu):

- Flutter với Dart 3+ (tương thích với constraint `sdk: ">=3.0.0 <4.0.0"` trong `pubspec.yaml`).
- Android/iOS emulator hoặc thiết bị thực tế.

Các bước build & chạy:

```bash
flutter pub get
flutter run
```

Ghi chú:
- `shared_preferences` yêu cầu cấu hình nền tảng bình thường (Android/iOS) — plugin sẽ tự động tích hợp khi chạy `flutter pub get` và build.

---

## Tệp quan trọng (tham khảo nhanh)

- [lib/main.dart](lib/main.dart)
- [lib/models/note_model.dart](lib/models/note_model.dart)
- [lib/viewmodels/note_viewmodel.dart](lib/viewmodels/note_viewmodel.dart)
- [lib/services/storage_service.dart](lib/services/storage_service.dart)
- [lib/views/home/home_screen.dart](lib/views/home/home_screen.dart)
- [lib/views/editor/editor_screen.dart](lib/views/editor/editor_screen.dart)

---
