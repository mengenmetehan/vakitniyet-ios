# 🚀 Hızlı Başlangıç

## ⚡️ 3 Adımda Başla

### 1️⃣ Xcode'da Config Dosyalarını Bağla

1. Xcode'da projeyi aç
2. Sol panelde **VakitNiyet** (mavi ikon) tıkla
3. **Info** sekmesi
4. **Configurations** bölümü

**Debug için:**
- Debug satırında sağdaki dropdown'dan `Configurations/Config.debug` seç

**Release için:**
- Release satırında sağdaki dropdown'dan `Configurations/Config.release` seç

### 2️⃣ URL'i Ayarla (İsteğe Bağlı)

**Development için:**
```bash
# Configurations/Config.debug.xcconfig dosyasını aç
BASE_URL = http:/$()/localhost:3000/v1/api
```

**Production için:**
```bash
# Configurations/Config.release.xcconfig dosyasını aç  
BASE_URL = https:/$()/api.vakitniyet.com/v1/api
```

### 3️⃣ Build Et

```
⌘ + B (Command + B)
```

✅ Hazır! 🎉

---

## 🔍 Çalışıyor mu Kontrol Et

Build ettikten sonra:

```swift
print(AppConfig.baseURL)
// Debug modda: http://localhost:3000/v1/api
// Release modda: https://api.vakitniyet.com/v1/api
```

---

## ❌ Hata Alıyorsan

**"BASE_URL bulunamadı" hatası:**

1. ✅ Config dosyaları `Configurations/` klasöründe mi?
2. ✅ Xcode'da bağlandı mı? (Project > Info > Configurations)
3. ✅ Clean Build: `⌘ + Shift + K` sonra `⌘ + B`

---

## 📝 URL Değiştirme

Backend URL değiştirmek için:

1. İlgili config dosyasını aç (`Config.debug.xcconfig` veya `Config.release.xcconfig`)
2. `BASE_URL` satırını düzenle
3. Kaydet ve build et: `⌘ + B`

**Kod değişikliği gerektirmez!** 🎯

---

## 🔒 Güvenlik

Config dosyaları otomatik olarak `.gitignore`'da:
```
✅ Config.example.xcconfig   → Git'e eklenir (template)
❌ Config.debug.xcconfig     → Git'e EKLENMEMELİ
❌ Config.release.xcconfig   → Git'e EKLENMEMELİ
```

---

## 🤝 Ekip Arkadaşın İçin

Yeni biri projeyi klonladığında:

```bash
# 1. Config dosyalarını oluştur
cd Configurations
cp Config.example.xcconfig Config.debug.xcconfig
cp Config.example.xcconfig Config.release.xcconfig

# 2. URL'leri düzenle
# Config.debug.xcconfig ve Config.release.xcconfig dosyalarını aç
# BASE_URL değerlerini güncelle

# 3. Xcode'da config'leri bağla (yukarıdaki adım 1)

# 4. Build et!
```

---

## 💡 İpucu

**Farklı backend URL'leri test etmek için:**

```bash
# Config.debug.xcconfig içinde:

# Local backend
BASE_URL = http:/$()/localhost:3000/v1/api

# Ngrok URL
# BASE_URL = http:/$()/abc123.ngrok-free.app/v1/api

# Test sunucusu
# BASE_URL = https:/$()/test.vakitniyet.com/v1/api
```

Sadece satır başındaki `#` karakterini kaldır/ekle! Yorum satırları işe yaramaz.

---

Detaylı bilgi için: [XCCONFIG_SETUP.md](XCCONFIG_SETUP.md)
