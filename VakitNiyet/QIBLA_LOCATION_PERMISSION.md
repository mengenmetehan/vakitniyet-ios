# ✅ Kıble İçin Gerekli İzinler

## 📍 Evet, Konum Gerekli!

Kıble yönü hesaplamak için **mutlaka** konum bilgisi gerekir çünkü:
- Her konumdan Mekke'ye olan açı farklıdır
- CompassManager konum + pusula verilerini birleştirir
- Qibla açısı = atan2(kullanıcı_konumu, Mekke_konumu)

---

## 🔐 Info.plist'e Eklenecek İzinler

### 1. Konum İzni (Zorunlu)

**Info.plist'e ekleyin:**

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Kıble yönünü hesaplamak ve namaz vakitlerini göstermek için konumunuz kullanılır.</string>
```

**Xcode'da manuel ekleme:**
```
1. Info.plist'e sağ tık
2. Open As > Source Code
3. Yukarıdaki XML'i <dict> içine yapıştır
```

**Veya Xcode UI'dan:**
```
1. Target seç
2. Info tab
3. Custom iOS Target Properties
4. + butonuna bas
5. "Privacy - Location When In Use Usage Description" seç
6. Value: "Kıble yönünü hesaplamak ve namaz vakitlerini göstermek için konumunuz kullanılır."
```

---

### 2. Pusula/Hareket İzni (Zorunlu)

**Info.plist'e ekleyin:**

```xml
<key>NSMotionUsageDescription</key>
<string>Pusula yönünü göstermek için cihaz sensörleri kullanılır.</string>
```

---

## 📱 Kullanıcı Deneyimi

### İlk Açılış:

1. **Kullanıcı Kıble sekmesine basar**
   
2. **iOS permission alert gösterir:**
   ```
   "VakitNiyet konumunuzu kullanmak istiyor"
   
   Kıble yönünü hesaplamak ve namaz vakitlerini
   göstermek için konumunuz kullanılır.
   
   [Allow While Using App]  [Don't Allow]
   ```

3. **Kullanıcı "Allow" derse:**
   - ✅ Konum alınır
   - ✅ Pusula başlar
   - ✅ Ok Kıble yönüne döner

4. **Kullanıcı "Don't Allow" derse:**
   - ❌ QiblaView şunu gösterir:
   ```
   🚫 Konum İzni Gerekli
   
   Kıble yönü için konum izni gereklidir.
   Ayarlar'dan konum erişimini açın.
   
   [Konum İzni Ver]
   ```

---

## 🔍 Konum Nasıl Kullanılıyor?

### CompassManager'da:

```swift
// 1. Konum alınıyor
func locationManager(_ manager: CLLocationManager, 
                    didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    
    userLocation = location.coordinate
    // Örnek: (41.0082, 28.9784) - İstanbul
}

// 2. Kıble açısı hesaplanıyor
let qiblaAngle = QiblaService.qiblaAngle(from: userLocation)
// İstanbul için ~147° (Güneydoğu)

// 3. Cihaz yönü alınıyor
let deviceHeading = trueHeading
// Örnek: 0° (Kuzey'e bakıyor)

// 4. Ok açısı hesaplanıyor
let arrowRotation = qiblaAngle - deviceHeading
// 147° - 0° = 147° dönecek (Güneydoğu'ya işaret edecek)
```

---

## ✅ Konum Doğruluğu

### Hassasiyet:

```swift
// CompassManager.swift
locationManager.desiredAccuracy = kCLLocationAccuracyBest
```

Bu ayar:
- ✅ En doğru konumu verir (GPS + Wi-Fi + Cellular)
- ✅ Kıble yönü doğru hesaplanır
- ⚠️ Biraz daha fazla pil kullanır (ama kabul edilebilir)

---

## 📊 Konum Kullanımı Özeti

| Özellik | Konum Gerekli? | Sebep |
|---------|----------------|-------|
| Kıble Yönü | ✅ Evet | Her konumdan Mekke farklı açıda |
| Namaz Vakitleri | ✅ Evet | Şehre göre vakit değişir |
| Pusula Ok | ✅ Evet | Relatif açı hesabı için |
| Kalibrasyon | ❌ Hayır | Sadece sensör doğruluğu |

---

## 🛡️ Gizlilik

### Kullanıcıya Güvence:

1. **"When In Use" izni** - Sadece uygulama açıkken
2. **Background location YOK** - Kapalıyken takip etmiyor
3. **Konum saklanmıyor** - Sadece anlık hesaplama
4. **3. parti paylaşım YOK** - Veriler cihazda kalıyor

### QiblaView'da gösterilebilir:

```swift
// Privacy note
Text("🔒 Konumunuz sadece Kıble yönü hesabı için kullanılır ve saklanmaz.")
    .font(.caption2)
    .foregroundColor(.white.opacity(0.5))
    .padding()
```

---

## 🚀 Test Senaryoları

### 1. İlk Kullanım (İzin Yok)
```
Kullanıcı Kıble'ye basar
  ↓
Permission alert çıkar
  ↓
"Allow" seçer
  ↓
Konum alınır (1-2 saniye)
  ↓
Pusula çalışır
  ✅ Başarılı!
```

### 2. İzin Reddedilmiş
```
Kullanıcı Kıble'ye basar
  ↓
QiblaView gösterir:
  "⚠️ Konum İzni Gerekli"
  [Konum İzni Ver] butonu
  ↓
Buton Settings'e yönlendirir
```

### 3. Konum Kapalı (iOS Settings)
```
iOS konum servisleri kapalı
  ↓
QiblaView uyarı gösterir
  ↓
Kullanıcıyı Settings > Privacy > Location'a yönlendirir
```

---

## 📝 Checklist - Kontrol Edin

- [ ] `NSLocationWhenInUseUsageDescription` Info.plist'te var mı?
- [ ] `NSMotionUsageDescription` Info.plist'te var mı?
- [ ] CompassManager `requestWhenInUseAuthorization()` çağırıyor mu?
- [ ] QiblaView permission denied durumunu gösteriyor mu?
- [ ] Gerçek cihazda test edildi mi?

---

## ✅ Özet

**Evet, konum şart!** 

Kıble yönü = Kullanıcı konumundan Mekke'ye olan açı

```
Kullanıcı (İstanbul): 41.0082°N, 28.9784°E
Mekke (Kabe):        21.4225°N, 39.8262°E

Kıble açısı = ~147° (Güneydoğu)
```

**Info.plist'e izinleri ekleyin ve test edin!** 🧭✨
