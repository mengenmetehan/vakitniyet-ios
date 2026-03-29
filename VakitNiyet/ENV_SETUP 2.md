# 🚀 Hızlı Kurulum - .env Kullanımı

## 1️⃣ .env Dosyasını Oluştur

```bash
# .env.example'dan kopyala
cp .env.example .env.development
cp .env.example .env.production

# .env.development'ı düzenle
vim .env.development
```

**`.env.development` içeriği:**
```bash
BASE_URL=http://localhost:3000/v1/api

# Ngrok kullanıyorsan:
# BASE_URL=http://your-ngrok-url.ngrok-free.app/v1/api
```

## 2️⃣ Xcode'a Ekle

1. Xcode'da **VakitNiyet** klasörüne sağ tık
2. **Add Files to "VakitNiyet"**
3. `.env.development` seç
4. ✅ **"Copy items if needed"** işaretle
5. ✅ **"Add to targets: VakitNiyet"** işaretle
6. **Add**

## 3️⃣ Run

```
⌘ + R
```

Konsolda göreceksiniz:
```
✅ BASE_URL loaded from .env: http://localhost:3000/v1/api
```

---

## 🔄 URL Değiştirme (Ngrok vb.)

1. `.env.development` dosyasını aç
2. URL'i değiştir:
   ```bash
   BASE_URL=http://new-url.ngrok-free.app/v1/api
   ```
3. Kaydet (⌘S)
4. Uygulamayı yeniden başlat (⌘R)

**İşte bu kadar!** 🎉

---

## 📁 Dosya Yapısı

```
.env.example         → Git'e eklenir (template)
.env.development     → Git'e EKLENMEMELİ (local URL'ler)
.env.production      → Git'e EKLENMEMELİ (production URL'ler)
```

---

## 💡 İpuçları

- **Ngrok URL her seferinde değişir** → .env'yi güncelleyin
- **Gerçek cihazda test** → Mac IP'nizi kullanın (`ipconfig getifaddr en0`)
- **Runtime'da okuyor** → Kod değişikliği gerektirmez

---

## ❓ Sorun mu var?

**Hata: ".env dosyası bulunamadı"**
- Dosya Xcode'da görünüyor mu?
- Target Membership işaretli mi?

**URL değişmiyor**
- Dosyayı kaydettiniz mi? (⌘S)
- Uygulamayı yeniden başlattınız mı? (⌘R)

---

Detaylı bilgi: [ENV_RUNTIME_GUIDE.md](ENV_RUNTIME_GUIDE.md)
