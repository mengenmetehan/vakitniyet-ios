# ✅ Test Checklist - Gerçek Cihaz

## 🔗 Backend Bilgileri

**Backend URL**: `https://raggedy-recklessly-jaelyn.ngrok-free.dev/v1`  
**Swagger UI**: `https://raggedy-recklessly-jaelyn.ngrok-free.dev/v1/swagger-ui/index.html`  
**iOS App URL**: `https://raggedy-recklessly-jaelyn.ngrok-free.dev/v1/api`

---

## 📋 Ön Hazırlık

### Backend Kontrol
- [ ] Backend çalışıyor (`http://localhost:8080`)
- [ ] Ngrok çalışıyor (`ngrok http 8080`)
- [ ] Swagger UI açılıyor (yukarıdaki link)
- [ ] Test endpoint çağrıldı (Swagger'dan herhangi biri)

### Xcode Kontrol
- [ ] Team seçildi (Signing & Capabilities)
- [ ] Bundle ID: `com.metehanmengen.vakitniyet.VakitNiyet`
- [ ] Sign in with Apple capability eklendi
- [ ] Push Notifications capability eklendi
- [ ] Background Modes → Remote notifications aktif
- [ ] NetworkService.swift → URL güncellendi ✅

### iPhone Kontrol
- [ ] iPhone USB ile bağlı
- [ ] iPhone unlocked
- [ ] Wi-Fi'a bağlı
- [ ] iOS 17.0+
- [ ] Apple ID ile giriş yapılmış

---

## 🧪 Test Senaryoları

### 1️⃣ Backend Test (Swagger'dan)

**Test 1: Public Endpoint**
```
GET /api/public/location/countries
Expected: 200 OK
Response: [ { "UlkeID": "2", "UlkeAdi": "Türkiye" }, ... ]
```

**Test 2: Health Check** (varsa)
```
GET /actuator/health
Expected: 200 OK
```

---

### 2️⃣ iOS App Test

#### A. Apple Sign In
```
1. Xcode'da ⌘ + R
2. iPhone'da uygulama açıldı
3. "Sign in with Apple" butonuna tıkla
4. Apple ID seç
5. Face ID / Touch ID onayla
```

**Beklenen Sonuç:**
```
✅ Console: "Signed in successfully: [UUID]"
✅ Ana ekrana yönlendirildi
✅ Backend'de log: "POST /api/auth/apple - 200 OK"
```

**Hata Durumu:**
- ❌ "Failed to sign in" → Xcode Team ayarlarını kontrol et
- ❌ "Network error" → Backend/Ngrok çalışıyor mu?

---

#### B. Prayer Today - Backend Sync
```
1. Ana ekranda namaz listesi görünmeli
2. Loading indicator göründü mü?
3. 5 namaz listelenmiş mi?
```

**Beklenen Sonuç:**
```
✅ Console: "GET /api/prayer/today - 200 OK"
✅ Backend log: "GET /api/prayer/today - 200 OK"
✅ Namaz listesi görünüyor
```

**Hata Durumu:**
- ❌ Empty list → Backend'de user için prayer kaydı var mı?
- ❌ Loading forever → Network timeout, backend yanıt vermiyor

---

#### C. Prayer Toggle
```
1. Bir namazı tıkla (örn: Sabah)
2. Checkmark değişti mi?
3. Tekrar tıkla (toggle)
```

**Beklenen Sonuç:**
```
✅ Console: "🔄 Toggle called for: Sabah"
✅ Console: "✅ Toggle response: true/false"
✅ Backend log: "POST /api/prayer/toggle - 200 OK"
✅ UI güncellendi
```

**Hata Durumu:**
- ❌ Toggle çalışmıyor → Console'da error var mı?
- ❌ "Unauthorized" → Token geçersiz, logout/login yap

---

#### D. Location Selection
```
1. Settings tabına git
2. "Konum" tıkla
3. Ülke seç (Türkiye otomatik seçilmeli)
4. Şehir seç (örn: İstanbul)
5. İlçe seç (örn: Kadıköy)
6. "Kaydet" tıkla
```

**Beklenen Sonuç:**
```
✅ Console: "GET /api/public/location/countries - 200 OK"
✅ Console: "GET /api/public/location/cities?ulkeId=2 - 200 OK"
✅ Console: "GET /api/public/location/districts?ilId=34 - 200 OK"
✅ Backend log: Üç GET isteği
✅ Ana ekrana döndü, vakitler güncellendi
```

**Hata Durumu:**
- ❌ Empty list → Backend Diyanet API'ye erişemiyor
- ❌ Network error → URL doğru mu?

---

#### E. Notification Permission
```
1. Settings → "Bildirimleri Aç" butonuna tıkla
2. iOS permission dialog'u göründü mü?
3. "Allow" tıkla
```

**Beklenen Sonuç:**
```
✅ Console: "📱 Device Token: [hex string]"
✅ Backend log: "PUT /api/auth/device-token - 200 OK"
✅ Settings'te notification toggle açık
```

**Hata Durumu:**
- ❌ Device token null → Gerçek cihaz kullanıyorsun, değil mi?
- ❌ Permission denied → iPhone Settings → VakitNiyet → Notifications

---

#### F. Notification Settings
```
1. Settings → Notification ayarları değiştir
   - Offset: 10 dk
   - Content: Karma
   - Prayer toggles: Sabah, Öğle aktif
2. Kaydet (otomatik backend'e gitmeli)
```

**Beklenen Sonuç:**
```
✅ Console: "✅ Notification settings updated"
✅ Backend log: "PUT /api/notification/settings - 200 OK"
```

---

#### G. Streak & Stats
```
1. Ana ekranda streak sayısı görünüyor mu?
2. Stats tabına git
3. İstatistikler yüklendi mi?
```

**Beklenen Sonuç:**
```
✅ Console: "GET /api/prayer/streak - 200 OK"
✅ Console: "GET /api/prayer/stats - 200 OK"
✅ Backend log: İki GET isteği
```

---

#### H. Month Calendar
```
1. Ana ekranda takvim görünüyor mu?
2. Bugünün günü highlighted mı?
3. Geçmiş günler prayer count gösteriyor mu?
```

**Beklenen Sonuç:**
```
✅ Console: "GET /api/prayer/month?year=2026&month=3 - 200 OK"
✅ Backend log: GET isteği
✅ Takvim render oldu
```

---

#### I. Logout
```
1. Settings → "Çıkış Yap"
2. Confirmation dialog varsa onayla
```

**Beklenen Sonuç:**
```
✅ Sign In ekranına döndü
✅ Token'lar silindi (UserDefaults)
✅ Tekrar Sign In yapılabiliyor
```

---

## 🐛 Debug Checklist

### Console Log Kontrol

**Başarılı akış görmeliyiz:**
```
✅ Signed in successfully: [userId]
✅ GET /api/prayer/today - 200 OK
📱 Device Token: [token]
✅ PUT /api/auth/device-token - 200 OK
✅ GET /api/public/location/countries - 200 OK
🔄 Toggle called for: Sabah
✅ Toggle response: true
✅ POST /api/prayer/toggle - 200 OK
```

**Hata durumlarında:**
```
❌ Network error: ...
❌ Failed to sign in: ...
❌ Unauthorized
❌ Prayer not found: ...
```

---

### Backend Log Kontrol

**Başarılı akış:**
```
POST /api/auth/apple - 200 OK
GET /api/prayer/today - 200 OK
PUT /api/auth/device-token - 200 OK
GET /api/public/location/countries - 200 OK
POST /api/prayer/toggle - 200 OK
GET /api/prayer/streak - 200 OK
```

**Hata durumları:**
```
POST /api/auth/apple - 401 Unauthorized
GET /api/prayer/today - 500 Internal Server Error
POST /api/prayer/toggle - 404 Not Found
```

---

### Network Inspector (Xcode)

```
1. Xcode → Debug → Network → Enable Network Traffic Inspector
2. Request/Response detaylarını gör
3. Header, Body, Status code kontrol et
```

---

## 📊 Test Sonuçları

### ✅ Başarılı Test Kriterleri
- [ ] Apple Sign In çalıştı
- [ ] Prayer list backend'den geldi
- [ ] Toggle backend'e kaydedildi
- [ ] Location selection çalıştı
- [ ] Notification permission alındı
- [ ] Device token backend'e gitti
- [ ] Streak/Stats görüntülendi
- [ ] Logout çalıştı

### 🎉 TAM BAŞARI!
Tüm testler geçtiyse:
- Backend entegrasyonu doğrulandı ✅
- Apple Sign In çalışıyor ✅
- Push notification hazır ✅
- Production'a hazır ✅

---

## 🚨 Yaygın Sorunlar

### 1. "The operation couldn't be completed"
**Sebep**: Backend yanıt vermiyor  
**Çözüm**: Backend/Ngrok çalışıyor mu kontrol et

### 2. "Unauthorized (401)"
**Sebep**: Token geçersiz  
**Çözüm**: Logout/Login yap, token refresh kontrol et

### 3. "Certificate validation failed"
**Sebep**: HTTPS sertifika sorunu  
**Çözüm**: Ngrok free plan için normal, Info.plist'e exception ekle (sadece development)

### 4. "Device token is nil"
**Sebep**: Simulator kullanılıyor  
**Çözüm**: Gerçek cihaz kullan

### 5. "Empty prayer list"
**Sebep**: Backend'de user için veri yok  
**Çözüm**: Backend'de otomatik today prayer creation var mı?

---

## 📝 Test Notları

**Test Tarihi**: _________________  
**Test Eden**: _________________  
**Backend Version**: _________________  
**iOS Version**: _________________  
**Xcode Version**: _________________  

**Genel Notlar**:
```

```

**Bulunan Buglar**:
```

```

**İyileştirme Önerileri**:
```

```

---

## 🎯 Sonraki Adımlar

Test başarılı ise:
1. ✅ Backend'i production'a deploy et
2. ✅ APNs key backend'e ekle
3. ✅ Production URL kullan
4. ✅ TestFlight build oluştur
5. ✅ Beta testerlar ekle
6. ✅ App Store submission

---

**Happy Testing! 🚀**
