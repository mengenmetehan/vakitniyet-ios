# 📱 Gerçek Cihazda Test Rehberi

## 🎯 Gereksinimler

### 1. Apple Developer Account
- ✅ Ücretsiz veya ücretli hesap
- ✅ Sign in with Apple capability için Team ID gerekli

### 2. Fiziksel iPhone/iPad
- ✅ iOS 17.0 veya üzeri
- ✅ Apple ID ile giriş yapılmış
- ✅ USB kablosu ile Mac'e bağlı

### 3. Backend Hazır
- ✅ Backend çalışıyor olmalı
- ✅ API endpoint'leri erişilebilir

---

## 📋 Adım Adım Test Süreci

### ADIM 1: Xcode Projesini Hazırla

#### 1.1 Signing & Capabilities
```
1. Xcode'da projeyi aç
2. Project Navigator'da projeyi seç
3. TARGETS → VakitNiyet seç
4. "Signing & Capabilities" tabına git
```

#### 1.2 Team Seç
```
Team: Kendi Apple Developer hesabınızı seçin
Bundle Identifier: com.metehanmengen.vakitniyet.VakitNiyet (benzersiz olmalı)
```

#### 1.3 Capability'leri Ekle
Sol altta **"+ Capability"** butonuna tıklayıp şunları ekleyin:

**✅ Sign in with Apple**
```
Automatically → Xcode otomatik ekleyecek
```

**✅ Push Notifications**
```
Automatically → Xcode otomatik ekleyecek
```

**✅ Background Modes**
```
☑️ Remote notifications
```

---

### ADIM 2: Apple Developer Portal Ayarları

#### 2.1 App ID Oluştur/Kontrol Et
```
1. https://developer.apple.com/account
2. Certificates, Identifiers & Profiles → Identifiers
3. App IDs → com.metehanmengen.vakitniyet.VakitNiyet
```

**Capabilities aktif mi kontrol et:**
- ✅ Sign in with Apple
- ✅ Push Notifications

#### 2.2 APNs Key Oluştur (Push Notifications için)
```
1. Keys → + butonuna tıkla
2. Key Name: VakitNiyet APNs Key
3. ☑️ Apple Push Notifications service (APNs)
4. Continue → Register → Download
```

**ÖNEMLİ**: 
- `.p8` dosyasını kaydedin (bir kez indirilebilir)
- Key ID'yi kaydedin
- Team ID'yi kaydedin

#### 2.3 Backend'e APNs Bilgilerini Ekle
Backend'inizde bu bilgileri kullanın:
```properties
# application.properties (Spring Boot örneği)
apns.key-id=ABCDE12345
apns.team-id=TEAM123456
apns.key-path=/path/to/AuthKey_ABCDE12345.p8
apns.topic=com.metehanmengen.vakitniyet.VakitNiyet
```

---

### ADIM 3: Backend'i Hazırla

#### 3.1 Backend'i Çalıştır
```bash
# Terminal'de backend projenize gidin
cd /path/to/backend

# Spring Boot başlat
./mvnw spring-boot:run

# Veya
java -jar target/vakit-niyet-backend.jar
```

#### 3.2 Backend URL'ini Ayarla

**ÖNEMLI**: Backend localhost'ta çalışıyorsa, gerçek cihaz erişemez!

**Seçenek A: Ngrok Kullan** (Önerilen - Geliştirme için)
```bash
# Ngrok yükleyin
brew install ngrok

# Backend'i expose edin
ngrok http 8080

# Çıktıdan HTTPS URL'ini alın:
# Forwarding: https://abc123.ngrok.io -> http://localhost:8080
```

**Seçenek B: Backend'i Cloud'a Deploy Edin**
- Railway.app
- Fly.io
- AWS/Heroku/vb.

**NetworkService.swift'i güncelle:**
```swift
// NetworkService.swift
private let baseURL = "https://abc123.ngrok.io/v1/api"  // Ngrok URL
// VEYA
private let baseURL = "https://api.vakitniyet.app/v1/api"  // Production URL
```

---

### ADIM 4: iOS Uygulamasını Cihaza Yükle

#### 4.1 Cihazı Seç
```
1. iPhone'u USB ile Mac'e bağlayın
2. Xcode'da üst menüden cihazınızı seçin
   (Simulator yerine "Your iPhone Name")
```

#### 4.2 Trust Developer
```
1. İlk kez yükleme yapıyorsanız iPhone'da:
   Settings → General → VPN & Device Management
2. Developer App altında profilinizi bulun
3. "Trust [Your Name]" tıklayın
```

#### 4.3 Build & Run
```
Xcode'da: ⌘ + R (Command + R)
```

---

### ADIM 5: Test Senaryoları

#### ✅ Test 1: Apple Sign In
```
1. Uygulamayı açın
2. "Sign in with Apple" butonuna tıklayın
3. Apple ID seçin / Face ID / Touch ID onaylayın
4. İlk giriş: Ad soyad paylaşımını onaylayın
5. ✅ Ana ekrana yönlendirilmelisiniz
```

**Console log'larını kontrol edin:**
```
✅ Signed in successfully: [UUID]
📱 Device Token: [hex string]
```

#### ✅ Test 2: Backend Bağlantısı
```
1. Ana ekranda namaz listesi görünmeli
2. Bir namaz işaretleyin
3. Backend'e toggle request gitmelidir
```

**Backend log'larını kontrol edin:**
```
POST /api/prayer/toggle - 200 OK
```

#### ✅ Test 3: Location Seçimi
```
1. Settings → Konum
2. Türkiye → Şehir → İlçe seçin
3. Namaz vakitleri Diyanet'ten çekilmelidir
```

#### ✅ Test 4: Push Notification
```
1. Settings → Bildirimleri Aç
2. İzin verin
3. Device token backend'e gitmelidir
```

**Backend'den test notification gönderin:**
```bash
# Backend'de test endpoint çağırın (varsa)
POST /api/notification/test
```

#### ✅ Test 5: Logout
```
1. Settings → Çıkış Yap
2. Sign In ekranına dönülmelidir
3. Token'lar silinmelidir
```

---

### ADIM 6: Debug & Troubleshooting

#### Console Log'larını İzleyin
```
Xcode → View → Debug Area → Show Debug Area (⌘ + Shift + Y)
```

**Önemli log'lar:**
```swift
✅ Signed in successfully: [userId]
📱 Device Token: [token]
🔄 Toggle called for: Sabah
✅ Toggle response: true
📡 GET /api/prayer/today - 200 OK
❌ Network error: ...
```

#### Yaygın Hatalar ve Çözümleri

**Hata 1: "Failed to sign in with Apple"**
```
Çözüm:
- Xcode'da Team seçili mi?
- Bundle ID doğru mu?
- Sign in with Apple capability ekli mi?
- Apple Developer Portal'da App ID onaylı mı?
```

**Hata 2: "Network request failed"**
```
Çözüm:
- Backend çalışıyor mu?
- Ngrok aktif mi?
- NetworkService.swift'te URL doğru mu?
- iPhone Wi-Fi'a bağlı mı?
```

**Hata 3: "Device token not received"**
```
Çözüm:
- Push Notifications capability ekli mi?
- Gerçek cihaz kullanılıyor mu? (Simulator'da çalışmaz)
- AppDelegate.swift düzgün bağlı mı?
```

**Hata 4: "Unauthorized (401)"**
```
Çözüm:
- Token'lar kaydedildi mi?
- Backend token validation doğru mu?
- Token expire olmadı mı?
```

---

### ADIM 7: Production Hazırlığı

#### Info.plist Eklemeleri
```xml
<key>NSUserTrackingUsageDescription</key>
<string>Kişiselleştirilmiş içerik sunmak için kullanılır</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Namaz vakitlerini konumunuza göre ayarlamak için kullanılır</string>

<key>NSUserNotificationsUsageDescription</key>
<string>Namaz vakti hatırlatmaları göndermek için kullanılır</string>
```

#### Build Configuration
```
Scheme → Edit Scheme → Run
Build Configuration: Release (Production test için)
```

#### Archive & TestFlight
```
1. Product → Archive
2. Distribute App → TestFlight
3. Beta testerlar ekleyin
```

---

## 📊 Checklist

### Xcode Ayarları
- [ ] Team seçildi
- [ ] Bundle ID benzersiz
- [ ] Sign in with Apple capability eklendi
- [ ] Push Notifications capability eklendi
- [ ] Background Modes → Remote notifications aktif

### Apple Developer Portal
- [ ] App ID oluşturuldu
- [ ] Sign in with Apple aktif
- [ ] Push Notifications aktif
- [ ] APNs Key oluşturuldu (.p8 indirildi)

### Backend
- [ ] Backend çalışıyor
- [ ] Ngrok/Cloud URL hazır
- [ ] APNs key bilgileri eklendi
- [ ] Database hazır
- [ ] API endpoint'leri test edildi

### iOS App
- [ ] NetworkService.swift → URL güncellendi
- [ ] Info.plist izinleri eklendi
- [ ] Gerçek cihazda build başarılı
- [ ] Trust developer yapıldı

### Test Sonuçları
- [ ] Apple Sign In çalışıyor
- [ ] Backend'e bağlanıyor
- [ ] Prayer toggle çalışıyor
- [ ] Location selection çalışıyor
- [ ] Push notification izni alınıyor
- [ ] Device token backend'e gidiyor
- [ ] Logout çalışıyor

---

## 🚨 Acil Durum Notları

### Backend Erişilemiyorsa
PrayerStore zaten mock data kullanıyor, UI test edilebilir.

### Apple Sign In Çalışmıyorsa
1. Developer Portal'da App ID kontrol edin
2. Xcode'da Clean Build Folder (⌘ + Shift + K)
3. Cihazdan uygulamayı silin ve tekrar yükleyin

### Push Notification Çalışmıyorsa
Gerçek notification testi backend ready olduğunda yapılabilir. Şimdilik device token alınması yeterli.

---

## 📞 İletişim

**Backend API**: `http://localhost:8080/v1` → Ngrok ile expose edin  
**Xcode Version**: 15.0+  
**iOS Deployment Target**: 17.0  
**Swift Version**: 5.9+  

---

**Test Başarıyla Tamamlandığında:**
✅ Backend entegrasyonu doğrulandı  
✅ Apple Sign In çalışıyor  
✅ Push notification hazır  
✅ Production'a hazır  

🎉 Tebrikler!
