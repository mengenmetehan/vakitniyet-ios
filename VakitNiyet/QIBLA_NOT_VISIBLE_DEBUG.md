# 🔍 Kıble Bulucu Görünmüyor - Debug

## Adım Adım Kontrol

### 1️⃣ TabView Dosyasını Bulun

Şu dosyalardan birini açın:
- `ContentView.swift`
- `HomeView.swift`
- `MainView.swift`
- `RootView.swift`

**Nasıl bulunur:**
```
Xcode'da ⌘ + Shift + O (Quick Open)
"ContentView" yazın ve açın
```

---

### 2️⃣ TabView İçinde QiblaView Var mı Kontrol Edin

**Şu şekilde olmalı:**

```swift
TabView {
    // Bugün view
    SomeView()
        .tabItem {
            Label("Bugün", systemImage: "calendar")
        }
    
    // ✅ QIBLA VIEW OLMALI
    QiblaView()
        .tabItem {
            Label("Kıble", systemImage: "location.north.fill")
        }
    
    // Diğer view'lar...
}
```

**Yoksa ekleyin!**

---

### 3️⃣ Import SwiftUI Var mı?

Dosyanın başında olmalı:
```swift
import SwiftUI
```

---

### 4️⃣ QiblaView Dosyası Proje Hedefine Ekli mi?

**Kontrol:**
```
1. Xcode'da QiblaView.swift'e tıklayın
2. Sağ panelde File Inspector açın (⌥⌘1)
3. "Target Membership" bölümünde
4. "VakitNiyet" checkbox işaretli olmalı ✅
```

**Değilse:**
```
VakitNiyet checkbox'ını işaretleyin
```

---

### 5️⃣ Build Başarılı mı?

```bash
⌘ + Shift + K  # Clean
⌘ + B          # Build
```

**Build log'da hata var mı?**
- Color.hex hatası varsa: BUILD_FIX_FINAL.md'ye bakın
- Başka hata varsa: Bildirin

---

### 6️⃣ Debug: QiblaView'ı Doğrudan Test Edin

**VakitNiyetApp.swift'i geçici olarak değiştirin:**

```swift
@main
struct VakitNiyetApp: App {
    var body: some Scene {
        WindowGroup {
            // GEÇICI TEST
            QiblaView()
            
            // Normal (yorum satırında)
            // ContentView()
        }
    }
}
```

**Build ve Run:**
```
⌘ + R
```

**QiblaView görünüyorsa:**
- ✅ QiblaView çalışıyor
- ❌ TabView'a eklenmemiş

**Görünmüyorsa:**
- ❌ Build hatası var
- ❌ Target membership yanlış

---

## 🎯 En Olası Sorunlar

### Sorun 1: TabView'a Eklenmemiş

**Çözüm:**
ContentView.swift'te TabView içine ekleyin:

```swift
QiblaView()
    .tabItem {
        Label("Kıble", systemImage: "location.north.fill")
    }
```

---

### Sorun 2: Import Eksik

**Hata:**
```
Cannot find 'QiblaView' in scope
```

**Çözüm:**
```swift
import SwiftUI
```

---

### Sorun 3: Target Membership Yanlış

**Belirti:**
Build başarılı ama QiblaView bulunamıyor

**Çözüm:**
```
QiblaView.swift > File Inspector > Target Membership > VakitNiyet ✅
```

---

### Sorun 4: Color.hex Hatası

**Hata:**
```
Invalid redeclaration of 'init(hex:)'
```

**Çözüm:**
BUILD_FIX_FINAL.md dosyasına bakın

---

## 📋 Hızlı Checklist

```
[ ] QiblaView.swift proje içinde var
[ ] Target membership işaretli
[ ] TabView içinde QiblaView() eklendi
[ ] Build başarılı (⌘ + B)
[ ] Info.plist izinleri eklendi
[ ] Gerçek cihazda test ediliyor
```

---

## 💡 Hızlı Fix Kodları

### Minimal TabView Örneği:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Text("Bugün")
                .tabItem {
                    Label("Bugün", systemImage: "calendar")
                }
            
            QiblaView()
                .tabItem {
                    Label("Kıble", systemImage: "safari.fill")
                }
            
            Text("Ayarlar")
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape")
                }
        }
    }
}
```

---

## 🔧 Test Komutu

Terminal'de:
```bash
# QiblaView dosyası var mı?
find . -name "QiblaView.swift"

# Çıktı olmalı:
# ./VakitNiyet/Features/Qibla/QiblaView.swift
```

---

## 📞 Bana Bildirin

Hangi dosyayı düzenliyorsunuz? 

**Şunları paylaşın:**
1. ContentView.swift içeriği (TabView bölümü)
2. Build hataları varsa console log
3. QiblaView.swift target membership durumu

**O zaman tam çözüm verebilirim!** 🚀
