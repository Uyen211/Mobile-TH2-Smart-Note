# 🔐 Google Sign-In Setup - Quick Guide

## ✅ Hiện tại

- **Login Screen**: Chỉ hiển thị nút "Đăng nhập bằng Google"
- **App Status**: ✅ Chạy thành công
- **Supabase**: ✅ Khởi tạo xong

---

## 🔧 Để Google Sign-In hoạt động trên Web

### Option 1: Setup Supabase Redirect (RECOMMENDED)

1. **Mở Supabase Dashboard**
   - URL: https://supabase.com/dashboard

2. **Tìm Project → Authentication → URL Configuration**

3. **Thêm Redirect URLs** (add both):
   ```
   http://localhost:5000
   http://localhost:5000/
   http://localhost:8080
   http://localhost:8080/
   ```

4. **Enable Google OAuth Provider**
   - Authentication → Providers → Google
   - Enable nó
   - Thêm Google Client ID & Secret (từ Google Cloud Console)

5. **Restart Flutter app**:
   ```bash
   flutter run -d edge
   ```

### Option 2: Quick Test (No Setup)

Nếu chưa muốn setup, test Email/Password trước:

1. Uncomment phần Email/Password trong LoginScreen
2. Hoặc tạo tài khoản test qua Supabase Console

---

## 🔍 Troubleshooting

| Vấn đề | Giải pháp |
|--------|----------|
| Google button không có phản ứng | Check web console (F12 → Console) xem có error không |
| Redirect URL error | Xác nhận URL trong Supabase URL Configuration |
| CORS error | Thêm localhost URL vào Supabase Authorized Domains |

---

## 📱 Trên Mobile (iOS/Android)

Google Sign-In đã configured sẵn với deep link:
```
io.supabase.smartnote://login-callback/
```

Chỉ cần build & deploy → automatic sẽ hoạt động!

---

## 💡 Development Tips

- **Hot Reload**: Press `r` trong terminal
- **Hot Restart**: Press `R` 
- **View Logs**: Bất cứ lúc nào F12 → Console

---

**Vậy là xong setup rồi! 🚀**

Bạn có thể test ngay bằng cách click nút "Đăng nhập bằng Google"
