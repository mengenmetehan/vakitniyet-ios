# 🚀 Runtime .env Kullanımı

## ⚡️ Çok Basit - 3 Adım

### 1️⃣ .env Dosyasını Xcode'a Ekle

1. Xcode'da proje navigatörde **VakitNiyet** klasörüne sağ tık
2. **Add Files to "VakitNiyet"**
3. `.env.development` dosyasını seç
4. ✅ **"Copy items if needed"** işaretle
5. ✅ **"Add to targets: VakitNiyet"** işaretle
6. **Add** tıkla

### 2️⃣ URL Değiştir

**`.env.development`** dosyasını aç ve düzenle:

```bash
# Ngrok URL kullanmak için:
BASE_URL=http://abc123.ngrok-free.app/v1/api

# Veya local:
# BASE_URL=http://localhost:3000/v1/api

# Veya başka bir URL:
# BASE_URL=http://192.168.1.100:8080/v1/api
```

### 3️⃣ Uygulamayı Yeniden Başlat

```
⌘ + R
```

✅ Yeni URL yüklendi! 🎉

---

## 🔍 Nasıl Çalışır?

```
1. Uygulama başladığında
   ↓
2. EnvironmentLoader .env dosyasını okur
   ↓
3. AppConfig.baseURL değeri yüklenir
   ↓
4. NetworkService bu URL'i kullanır
```

**Runtime'da okuyor!** Build script yok, xcconfig yok!

---

## 💡 URL Değiştirme

### Ngrok URL Aldığınızda:

```bash
# Terminal'de ngrok başlat
ngrok http 8080

# Aldığınız URL'i kopyalayın
# Örnek: http://abc123.ngrok-free.app
```

**Xcode'da `.env.development` dosyasını aç:**

```bash
BASE_URL=http://abc123.ngrok-free.app/v1/api
```

**Kaydet ve uygulamayı yeniden başlat:**
```
⌘ + R
```

**Konsolda göreceksiniz:**
```
✅ BASE_URL loaded from .env: http://abc123.ngrok-free.app/v1/api
```

---

## 📱 Gerçek Cihazda Test

Gerçek iPhone'da test ederken:

**1. Mac ve iPhone aynı Wi-Fi'da olmalı**

**2. `.env.development` dosyasını düzenle:**
```bash
# Mac'inizin local IP adresini kullanın
BASE_URL=http://192.168.1.100:3000/v1/api
```

**3. Mac'inizin IP adresini bulun:**
```bash
ifconfig | grep "inet "
# veya
ipconfig getifaddr en0
```

---

## 🎯 Debug vs Release

### Debug Modda (Development):
```swift
// .env.development dosyası okunur
AppConfig.baseURL // -> http://localhost:3000/v1/api
```

### Release Modda (Production):
```swift
// .env.production dosyası okunur
AppConfig.baseURL // -> https://api.vakitniyet.com/v1/api
```

---

## 🔧 Sorun Giderme

### Hata: ".env dosyası bulunamadı"

**Çözüm:**
1. `.env.development` dosyası Xcode'da görünüyor mu?
2. File Inspector'da (⌥⌘1) "Target Membership" bölümünde VakitNiyet işaretli mi?
3. Dosya kopyalandı mı? ("Copy items if needed" seçili miydi?)

### URL Değişmiyor

**Çözüm:**
1. `.env.development` dosyasını düzenlediniz mi?
2. Kaydettiniz mi? (⌘S)
3. Uygulamayı yeniden başlattınız mı? (⌘R)
4. Clean build deneyin: ⌘ + Shift + K, sonra ⌘ + R

### Dosya Bulunamadı (Bundle)

**Xcode'da dosyayı kontrol edin:**
```
1. .env.development dosyasına tıklayın
2. Sağ panelde File Inspector (⌥⌘1)
3. "Target Membership" bölümünde "VakitNiyet" işaretli olmalı
```

---

## 🌟 Avantajlar

### ✅ Runtime'da Okuyor
- Kod değişikliği yok
- Build script yok
- Sadece dosyayı düzenle ve yeniden başlat

### ✅ Hızlı Test
- Ngrok URL aldınız? Hemen değiştirin!
- Local IP değişti? Saniyede güncelleyin!
- Backend URL değişti? Anında adapte olun!

### ✅ Güvenli
- `.env.development` ve `.env.production` Git'e eklenmez
- Her geliştirici kendi URL'ini kullanır
- Production URL'leri asla sızmaz

---

## 📝 Örnek Senaryolar

### Senaryo 1: Ngrok ile Test

```bash
# 1. Backend başlat
cd backend
./mvnw spring-boot:run

# 2. Ngrok başlat
ngrok http 8080
# URL: http://abc123.ngrok-free.app

# 3. .env.development düzenle
BASE_URL=http://abc123.ngrok-free.app/v1/api

# 4. Uygulamayı başlat
⌘ + R
```

### Senaryo 2: Gerçek Cihazda Local Test

```bash
# 1. Mac IP adresini bul
ipconfig getifaddr en0
# Örnek: 192.168.1.105

# 2. .env.development düzenle
BASE_URL=http://192.168.1.105:3000/v1/api

# 3. iPhone'u USB'ye tak (veya Wi-Fi'da ol)
# 4. Uygulamayı başlat
⌘ + R
```

### Senaryo 3: Test Sunucusu

```bash
# .env.development düzenle
BASE_URL=https://test-api.vakitniyet.com/v1/api

# Uygulamayı başlat
⌘ + R
```

---

## 🔒 Güvenlik

`.gitignore` zaten koruyor:
```
✅ .env.example        → Git'e eklenir (template)
❌ .env.development    → Git'e EKLENMEMELİ
❌ .env.production     → Git'e EKLENMEMELİ
```

---

## 🤝 Ekip Çalışması

Yeni geliştirici ekibe katıldığında:

```bash
# 1. Repo'yu klonla
git clone https://github.com/user/VakitNiyet.git

# 2. .env dosyalarını oluştur
cp .env.example .env.development
cp .env.example .env.production

# 3. Kendi URL'lerini ekle
vim .env.development
# BASE_URL=http://localhost:3000/v1/api

# 4. Dosyayı Xcode'a ekle (Add Files to "VakitNiyet")

# 5. Run!
⌘ + R
```

---

## 💡 İpuçları

1. **Ngrok URL her başlatmada değişir** - .env'yi her seferinde güncelleyin
2. **Local IP değişebilir** - Mac IP'nizi kontrol edin
3. **https vs http** - Ngrok free tier http kullanır
4. **Port numaraları** - Backend portunu doğru yazın (:3000, :8080 vs.)

---

Artık URL değiştirmek çok kolay! Sadece dosyayı düzenle, kaydet, yeniden başlat! 🚀
