# Environment Kurulumu

Bu proje, gizli bilgileri (API URL'leri, anahtarlar vb.) korumak için environment dosyaları kullanır.

## 🚀 İlk Kurulum

### 1. Environment Dosyalarını Oluşturun

```bash
# .env.example'ı kopyalayın
cp .env.example .env.development
cp .env.example .env.production
```

### 2. Environment Dosyalarını Düzenleyin

**`.env.development`** (Development/Debug için):
```bash
BASE_URL=http://localhost:3000/v1/api

```

**`.env.production`** (Production/Release için):
```bash
BASE_URL=https://api.vakitniyet.com/v1/api
```

### 3. Xcode Build Script Kurulumu

⚠️ **ÖNEMLİ**: Bu adım sadece bir kez yapılır!

1. Xcode'da projenizi açın
2. Sol panelden **VakitNiyet** projesini seçin
3. **VakitNiyet** target'ını seçin
4. **Build Phases** sekmesine gidin
5. Sol üstteki **"+"** butonuna tıklayın
6. **"New Run Script Phase"** seçin
7. Yeni oluşan fazı genişletin ve şu script'i ekleyin:

```bash
# Environment Config Generator
bash "${SRCROOT}/Scripts/generate-config.sh"
```

8. Bu fazı **"Compile Sources"** fazının ÜSTÜNE sürükleyin (çok önemli!)
9. Faz ismini **"Generate Environment Config"** olarak değiştirin (opsiyonel ama önerilen)

### 4. Script'e Çalıştırma İzni Verin

Terminal'de:
```bash
chmod +x Scripts/generate-config.sh
```

### 5. Build Edin

Xcode'da **⌘B** (Command + B) ile build edin. Konsol çıktısında şunu görmelisiniz:

```
✅ GeneratedConfig.swift oluşturuldu
📍 Kullanılan .env dosyası: .env.development
🔗 BASE_URL: http://localhost:3000/v1/api
```

## 🔍 Nasıl Çalışır?

```
.env.development  ─┐
                   ├─> generate-config.sh ─> GeneratedConfig.swift
.env.production   ─┘
         │
         └─> AppConfig.swift (baseURL kullanır)
```

1. **Build öncesi**: `generate-config.sh` çalışır
2. **Environment seçimi**: Debug modda `.env.development`, Release modda `.env.production` okunur
3. **Code generation**: `GeneratedConfig.swift` otomatik oluşturulur
4. **Compile**: Kod normal şekilde derlenir

## 📁 Dosya Yapısı

```
VakitNiyet/
├── .env.example          # Template (GIT'e eklenir)
├── .env.development      # Development ayarları (GIT'e EKLENMEMELİ)
├── .env.production       # Production ayarları (GIT'e EKLENMEMELİ)
├── Scripts/
│   └── generate-config.sh
├── VakitNiyet/
│   ├── AppConfig.swift   # Ana config dosyası
│   └── Generated/        # Otomatik oluşturulan dosyalar (GIT'e EKLENMEMELİ)
│       └── GeneratedConfig.swift
```

## ⚠️ Önemli Notlar

### Güvenlik
- ❌ `GeneratedConfig.swift` dosyasını GIT'e eklemeyin!
- ✅ Sadece `.env.example` dosyası GIT'e eklenmelidir

### Build Hatası Alırsanız

**Hata**: `Cannot find 'GeneratedConfig' in scope`

**Çözüm**:
1. Build script'in doğru kurulduğundan emin olun
2. Script'in "Compile Sources"'tan önce çalıştığından emin olun
3. Temiz build yapın: **⌘ + Shift + K** sonra **⌘ + B**

**Hata**: `.env dosyası bulunamadı`

**Çözüm**:
1. `.env.development` ve `.env.production` dosyalarının proje kök dizininde olduğundan emin olun
2. Dosya isimlerinin tam olarak doğru olduğundan emin olun

### URL Değiştirme

Backend URL'inizi değiştirmek için:

1. İlgili `.env` dosyasını açın
2. `BASE_URL` değerini güncelleyin
3. Xcode'da temiz build yapın: **⌘ + Shift + K** sonra **⌘ + B**

## 🎯 Yeni Environment Değişkeni Eklemek

### 1. `.env` dosyalarına ekleyin:
```bash
BASE_URL=http://localhost:3000/v1/api
API_KEY=your-api-key-here
APP_SECRET=your-secret-here
```

### 2. `generate-config.sh` script'ini güncelleyin:
```bash
cat > "$OUTPUT_FILE" << EOF
enum GeneratedConfig {
    static let baseURL = "${BASE_URL}"
    static let apiKey = "${API_KEY}"
    static let appSecret = "${APP_SECRET}"
}
EOF
```

### 3. `AppConfig.swift`'te kullanın:
```swift
static let apiKey = GeneratedConfig.apiKey
```

## 🤝 Ekip Çalışması

Yeni bir geliştirici projeye katıldığında:

1. Repository'yi klonlar
2. `.env.example` dosyasını kopyalar
3. Kendi ortamına göre düzenler
4. Build eder

Herkes kendi local ayarlarını kullanabilir, kimsenin gizli bilgileri GIT'e yüklenmez! 🎉

## 📞 Yardım

Sorun yaşıyorsanız:
1. Bu dökümanı baştan sona okuyun
2. Build script'in doğru kurulduğundan emin olun
3. `.env` dosyalarının var olduğundan emin olun
4. Temiz build yapın

Hala çözülmediyse issue açın! 🙋‍♂️
