# 🔧 QiblaView Entegrasyonu

## Qibla View Görünmüyor mu?

QiblaView'ı uygulamanıza eklemeniz gerekiyor!

---

## ✅ Çözüm: ContentView'a Ekle

### Seçenek 1: TabView İçinde (Önerilen)

**ContentView.swift** veya ana view dosyanızı açın:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Mevcut home view
            HomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
            
            // ✅ QIBLA VIEW EKLE
            QiblaView()
                .tabItem {
                    Label("Kıble", systemImage: "location.north.fill")
                }
            
            // Mevcut settings view
            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
        }
        .accentColor(Color.hex("1B4332"))
    }
}
```

---

### Seçenek 2: NavigationLink Olarak

```swift
NavigationView {
    List {
        // Diğer navigation linkler...
        
        NavigationLink(destination: QiblaView()) {
            HStack {
                Image(systemName: "location.north.fill")
                    .foregroundColor(Color.hex("1B4332"))
                Text("Kıble Yönü")
            }
        }
    }
}
```

---

### Seçenek 3: Sheet/Modal Olarak

```swift
struct HomeView: View {
    @State private var showQibla = false
    
    var body: some View {
        VStack {
            // ... içerik
            
            Button("Kıble Yönü") {
                showQibla = true
            }
        }
        .sheet(isPresented: $showQibla) {
            QiblaView()
        }
    }
}
```

---

### Seçenek 4: Test İçin Direkt Göster

**VakitNiyetApp.swift** içinde geçici olarak:

```swift
@main
struct VakitNiyetApp: App {
    var body: some Scene {
        WindowGroup {
            // Geçici test için
            QiblaView()
            
            // Normal:
            // ContentView()
        }
    }
}
```

---

## 🎯 En Hızlı Test

1. **QiblaView_Preview oluştur:**

```swift
// QiblaView.swift dosyasının sonunda
#Preview {
    QiblaView()
}
```

2. **Xcode'da Preview aç:**
   - Canvas açılmazsa: `⌥ + ⌘ + Enter`
   - Preview'da QiblaView görünecek

---

## ✅ TabView Örneği (Full Code)

```swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            // Prayer Times
            PrayerTimesView()
                .tabItem {
                    Label("Vakitler", systemImage: "clock.fill")
                }
            
            // Qibla Compass
            QiblaView()
                .tabItem {
                    Label("Kıble", systemImage: "location.north.fill")
                }
            
            // Settings
            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
        }
        .accentColor(Color.hex("1B4332"))
    }
}
```

---

## 📱 Test Et

1. QiblaView'ı ContentView'a ekle
2. Build: `⌘ + B`
3. Run: `⌘ + R`
4. Tab bar'da "Kıble" sekmesine tıkla

**Gerçek cihazda test edin!** (Simülatörde pusula çalışmaz)

---

## ❓ Hala Görünmüyorsa

**Console'da log var mı?**
```
📍 Starting compass updates
🧭 Compass heading updates started
```

**Permission alert çıkıyor mu?**
- Konum izni verin
- Motion izni verin (Settings > Privacy)

**Build başarılı mı?**
```
⌘ + B
# Hatasız build olmalı
```

---

Hangi seçeneği denediniz? Sonucu bildirin! 🚀
