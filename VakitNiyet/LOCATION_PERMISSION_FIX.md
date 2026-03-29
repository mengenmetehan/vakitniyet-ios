# 🔴 KONUM İZNİ SORUNU - ÇÖZÜM

## ❌ Hata:

```
Location error: The operation couldn't be completed. (kCLErrorDomain error 1.)
```

**Anlamı:** Konum izni yok veya reddedilmiş!

---

## ✅ ÇÖZÜM: Info.plist'e İzinleri Ekleyin

### Yöntem 1: Xcode UI'dan (Kolay)

1. **Xcode'da projeyi açın**
2. **Sol panelde VakitNiyet target'ını seçin**
3. **"Info" sekmesine gidin**
4. **Custom iOS Target Properties** altında **"+" butonuna** basın

5. **İlk izin ekleyin:**
   - Key: `Privacy - Location When In Use Usage Description`
   - Value: `Kıble yönünü hesaplamak ve namaz vakitlerini göstermek için konumunuz kullanılır.`

6. **İkinci izin ekleyin:**
   - **"+" butonuna** tekrar basın
   - Key: `Privacy - Motion Usage Description`
   - Value: `Pusula yönünü göstermek için cihaz sensörleri kullanılır.`

7. **Kaydet:** `⌘ + S`

---

### Yöntem 2: Info.plist Dosyasını Direkt Düzenle

1. **Info.plist dosyasını bulun:**
   - Xcode'da sol panelde `Info.plist` ara
   - Sağ tık → **Open As → Source Code**

2. **`<dict>` tag'ı içine şu satırları ekleyin:**

```xml
<!-- Konum İzni -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Kıble yönünü hesaplamak ve namaz vakitlerini göstermek için konumunuz kullanılır.</string>

<!-- Pusula/Hareket İzni -->
<key>NSMotionUsageDescription</key>
<string>Pusula yönünü göstermek için cihaz sensörleri kullanılır.</string>
```

3. **Kaydet:** `⌘ + S`

---

## 🧹 Temizlik ve Yeniden Deneme

İzinleri ekledikten sonra:

```bash
# 1. Clean Build Folder
⌘ + Shift + K

# 2. Uygulamayı cihazdan/simülatörden SİLİN
# iPhone'da: App iconuna uzun bas → Delete

# 3. Build ve Run
⌘ + R
```

**ÖNEMLİ:** Uygulamayı silmeden permission dialog çıkmayabilir!

---

## 📱 Beklenen Davranış

Uygulama ilk kez açıldığında:

1. **Kıble sekmesine basarsınız**

2. **iOS permission alert çıkar:**
   ```
   "VakitNiyet" Would Like to Access Your Location
   
   Kıble yönünü hesaplamak ve namaz vakitlerini
   göstermek için konumunuz kullanılır.
   
   [Allow While Using App]  [Don't Allow]
   ```

3. **"Allow While Using App" seçin**

4. **Konum alınır, pusula başlar! ✅**

---

## 🔍 Kalibrasyon Uyarısı (Normal)

```
⚠️ Compass needs calibration - accuracy: 33.09
```

Bu **normal**! Pusula hassasiyeti düşükse gösterilir.

**Çözüm:**
- Telefonu 8 şeklinde hareket ettirin
- QiblaView'da kalibrasyon banner'ı görünecek
- Kalibrasyon yapıldıktan sonra ok daha stabil olur

---

## ✅ Checklist

İzinler eklendikten sonra kontrol edin:

- [ ] Info.plist'te `NSLocationWhenInUseUsageDescription` var mı?
- [ ] Info.plist'te `NSMotionUsageDescription` var mı?
- [ ] Clean build yapıldı mı? (`⌘ + Shift + K`)
- [ ] Uygulama cihazdan silindi mi?
- [ ] Yeniden build edildi mi? (`⌘ + R`)
- [ ] Permission alert çıktı mı?
- [ ] "Allow While Using App" seçildi mi?

---

## 🎯 Info.plist Tam Örnek

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... Mevcut key'ler ... -->
    
    <!-- Konum İzni -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Kıble yönünü hesaplamak ve namaz vakitlerini göstermek için konumunuz kullanılır.</string>
    
    <!-- Pusula/Hareket İzni -->
    <key>NSMotionUsageDescription</key>
    <string>Pusula yönünü göstermek için cihaz sensörleri kullanılır.</string>
</dict>
</plist>
```

---

## 📞 Hala Çalışmıyorsa

**Settings'de manuel kontrol:**

1. iPhone Settings açın
2. Privacy & Security → Location Services
3. VakitNiyet uygulamasını bulun
4. "While Using the App" seçili olmalı

**Yoksa:**
- Uygulamayı sil
- Info.plist'i kontrol et
- Yeniden build et

---

## 🚀 Özet

1. **Info.plist'e izinleri ekle** (yukarıdaki yöntemlerden biri)
2. **Clean build:** `⌘ + Shift + K`
3. **Uygulamayı sil** (iPhone'dan)
4. **Build ve run:** `⌘ + R`
5. **"Allow While Using App" seç**
6. **Kıble çalışacak! ✅**

---

**İzinleri ekleyin ve uygulamayı yeniden başlatın!** 🧭✨
