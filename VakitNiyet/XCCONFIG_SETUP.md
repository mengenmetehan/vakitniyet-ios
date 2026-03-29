# ⚡️ Hızlı Kurulum - xcconfig ile

## 🎯 En Basit Yöntem - Build Script YOK!

### 1️⃣ Config Dosyalarını Oluştur (Sadece bir kez)

Terminalden:
```bash
# Proje dizinine git
cd /path/to/VakitNiyet

# Config dosyalarını oluştur (zaten oluşturulmuş!)
# Config.debug.xcconfig ve Config.release.xcconfig dosyaları hazır
```

### 2️⃣ Xcode'da Config Dosyalarını Bağla

1. Xcode'da projeyi aç
2. Sol panelde **VakitNiyet** projesine tıkla (en üst)
3. **Info** sekmesine git
4. **Configurations** bölümünü bul

**Debug** için:
- Debug satırında VakitNiyet target'ının yanındaki dropdown'a tıkla
- **Config.debug** seç

**Release** için:
- Release satırında VakitNiyet target'ının yanındaki dropdown'a tıkla
- **Config.release** seç

### 3️⃣ URL Değiştir

Backend URL'ini değiştirmek için:

**Development için:**
```bash
# Config.debug.xcconfig dosyasını aç
BASE_URL = http:/$()/your-dev-url.com/v1/api
```

**Production için:**
```bash
# Config.release.xcconfig dosyasını aç
BASE_URL = https:/$()/your-prod-url.com/v1/api
```

⚠️ **DİKKAT**: `:/$()/` bu şekilde yazılmalı (Xcode'un gereksinimidir)

### 4️⃣ Build Et

```bash
⌘ + B
```

İşte bu kadar! 🎉

## 🔍 Nasıl Çalışır?

```
Config.debug.xcconfig  ──> Info.plist ──> AppConfig.swift
        │
        └─> Debug build'de kullanılır

Config.release.xcconfig ──> Info.plist ──> AppConfig.swift
        │
        └─> Release build'de kullanılır
```

## ✅ Avantajlar

- ✅ Build script yok
- ✅ Otomatik Debug/Release seçimi
- ✅ Git'e asla yüklenmiyor (otomatik ignore)
- ✅ Xcode native çözümü
- ✅ Çok hızlı ve basit

## 🔒 Güvenlik

`.gitignore` dosyasında otomatik olarak engellendi:
```
Config.debug.xcconfig   # ❌ Git'e eklenmez
Config.release.xcconfig # ❌ Git'e eklenmez
Config.example.xcconfig # ✅ Git'e eklenir (template)
```

## 🤝 Ekip Çalışması

Yeni geliştirici ekibe katıldığında:

1. Repository'yi klonlar
2. `Config.example.xcconfig` dosyasını kopyalar:
```bash
cp Config.example.xcconfig Config.debug.xcconfig
cp Config.example.xcconfig Config.release.xcconfig
```
3. URL'leri kendi ortamına göre düzenler
4. Xcode'da config'leri bağlar (yukarıdaki adım 2)
5. Build eder

## 🎯 Yeni Değişken Eklemek

### 1. Config dosyasına ekle:
```
BASE_URL = https:/$()/api.example.com/v1/api
API_KEY = my-secret-key-123
APP_SECRET = super-secret
```

### 2. Info.plist'e ekle:
```xml
<key>API_KEY</key>
<string>$(API_KEY)</string>
<key>APP_SECRET</key>
<string>$(APP_SECRET)</string>
```

### 3. AppConfig.swift'te kullan:
```swift
static let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
static let appSecret = Bundle.main.infoDictionary?["APP_SECRET"] as? String ?? ""
```

## ❓ Sorun Giderme

**Hata**: `BASE_URL bulunamadı!`

**Çözüm**:
1. Config dosyaları oluşturuldu mu?
2. Xcode'da Project > Info > Configurations bölümünde bağlandı mı?
3. Clean Build: ⌘ + Shift + K, sonra ⌘ + B

**Hata**: Config dosyası bulunamıyor

**Çözüm**:
Xcode'da config dosyalarını projeye ekleyin:
- Sağ tık > Add Files to "VakitNiyet"
- Config.debug.xcconfig ve Config.release.xcconfig seçin
- ⚠️ "Copy items if needed" seçmeyin!
- "Add to targets" seçmeyin!

## 🚀 Özet

```bash
# 1. Config oluştur (otomatik oluşturuldu)
# 2. Xcode'da bağla (Project > Info > Configurations)
# 3. Build et!
⌘ + B
```

**Artık URL'leri değiştirmek için sadece Config.debug.xcconfig veya Config.release.xcconfig dosyasını düzenlemeniz yeterli!**

Kod değişikliği YOK! Build script YOK! Sadece config dosyası! 🎉
