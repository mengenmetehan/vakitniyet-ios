# 🚀 Hızlı Başlangıç - Gerçek Cihazda Test

## 5 Dakikada Test Et!

### 1️⃣ Backend'i Hazırla (2 dk)

```bash
# Terminal'de backend klasörüne git
cd /path/to/backend

# Spring Boot başlat
./mvnw spring-boot:run

# Başka terminal'de Ngrok başlat
brew install ngrok  # İlk kez
ngrok http 8080
```

**Ngrok'tan aldığınız URL'i kopyalayın:**
```
https://abc123.ngrok.io
```

---

### 2️⃣ iOS Uygulaması Hazır! ✅

**NetworkService.swift** zaten güncellendi:

```swift
// NetworkService.swift - Satır 12
private let baseURL = "https://raggedy-recklessly-jaelyn.ngrok-free.dev/v1/api"
```

**Swagger UI Test:**
```
https://raggedy-recklessly-jaelyn.ngrok-free.dev/v1/swagger-ui/index.html
```

---

### 3️⃣ Xcode Ayarları (1 dk)

```
1. Xcode'da Signing & Capabilities → Team seç
2. + Capability → Sign in with Apple
3. + Capability → Push Notifications
4. iPhone'u USB ile bağla
5. Üstten iPhone'unu seç (Simulator değil!)
```

---

### 4️⃣ Çalıştır! (1 dk)

```
⌘ + R (Command + R)
```

**İlk kez yükleme:**
1. iPhone'da: Settings → General → VPN & Device Management
2. Developer App altında profilinizi bulun
3. "Trust" tıklayın

---

### 5️⃣ Test Et!

```
✅ Sign in with Apple butonuna tıkla
✅ Apple ID'ni seç
✅ Face ID / Touch ID onayla
✅ Ana ekrana girdin mi? BAŞARILI! 🎉
```

---

## 🔍 Log Kontrol

**Xcode Console'da görmek istediğiniz:**
```
✅ Signed in successfully: [UUID]
📱 Device Token: [token]
🔄 Toggle called for: Sabah
✅ Toggle response: true
```

**Backend Console'da görmek istediğiniz:**
```
POST /api/auth/apple - 200 OK
GET /api/prayer/today - 200 OK
POST /api/prayer/toggle - 200 OK
```

---

## ❌ Hata Alıyorsan?

### "Failed to sign in"
- Xcode'da Team seçili mi?
- Bundle ID benzersiz mi?

### "Network error"
- Backend çalışıyor mu? (`http://localhost:8080`)
- Ngrok aktif mi?
- iPhone Wi-Fi'a bağlı mı?
- NetworkService.swift'te URL doğru mu?

### "Cannot install app"
- iPhone'da Trust developer yaptın mı?
- USB kablosu bağlı mı?
- iPhone unlocked mı?

---

## 🎯 Ne Test Edeceksin?

- [x] Apple Sign In
- [x] Prayer Toggle (Backend sync)
- [x] Location Selection
- [x] Push Notification Permission
- [x] Logout

Detaylı rehber için: **REAL_DEVICE_TEST.md**

---

**Başarılı test sonrası ne yapacaksın?**
1. ✅ Backend Production'a deploy et
2. ✅ NetworkService.swift'te production URL kullan
3. ✅ TestFlight'a archive et
4. ✅ Beta testerlar ekle
5. ✅ App Store'a gönder

🚀 Haydi başla!
