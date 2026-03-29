# 🎯 TabView'a Qibla Ekleme

## Mevcut Yapınız:

```
TabView:
├── Bugün (Today)
├── İstatistik (Stats)
└── Ayarlar (Settings)
```

## Yeni Yapı:

```
TabView:
├── Bugün (Today)
├── Kıble (Qibla)      ← YENİ
├── İstatistik (Stats)
└── Ayarlar (Settings)
```

---

## ✅ Kod Değişikliği

Ana TabView dosyanızı bulun (muhtemelen **ContentView.swift** veya **HomeView.swift**) ve şu değişikliği yapın:

### Önce:

```swift
TabView {
    // Bugün
    TodayView() // veya HomeView()
        .tabItem {
            Label("Bugün", systemImage: "calendar")
        }
    
    // İstatistik
    StatsView() // veya StatisticsView()
        .tabItem {
            Label("İstatistik", systemImage: "chart.bar.fill")
        }
    
    // Ayarlar
    SettingsView()
        .tabItem {
            Label("Ayarlar", systemImage: "gearshape.fill")
        }
}
```

### Sonra:

```swift
TabView {
    // Bugün
    TodayView() // veya HomeView()
        .tabItem {
            Label("Bugün", systemImage: "calendar")
        }
    
    // ✅ QIBLA - YENİ!
    QiblaView()
        .tabItem {
            Label("Kıble", systemImage: "location.north.fill")
        }
    
    // İstatistik
    StatsView() // veya StatisticsView()
        .tabItem {
            Label("İstatistik", systemImage: "chart.bar.fill")
        }
    
    // Ayarlar
    SettingsView()
        .tabItem {
            Label("Ayarlar", systemImage: "gearshape.fill")
        }
}
.accentColor(Color.hex("1B4332")) // Yeşil tema
```

---

## 📝 Adım Adım:

1. **Xcode'da ContentView.swift (veya TabView içeren dosya) açın**

2. **TabView içinde "Bugün" view'ından sonra QiblaView ekleyin:**
   ```swift
   QiblaView()
       .tabItem {
           Label("Kıble", systemImage: "location.north.fill")
       }
   ```

3. **Build ve Run:**
   ```
   ⌘ + B
   ⌘ + R
   ```

4. **Tab bar'da 4 sekme göreceksiniz:**
   - 📅 Bugün
   - 🧭 Kıble (YENİ!)
   - 📊 İstatistik
   - ⚙️ Ayarlar

---

## 🎨 Icon Alternatifleri

Farklı icon denemek isterseniz:

```swift
// Pusula icon
systemImage: "location.north.fill"

// Alternatifler:
systemImage: "safari.fill"         // Pusula
systemImage: "location.circle.fill" // Konum işareti
systemImage: "scope"                // Hedef
systemImage: "arrow.up.circle.fill" // Ok işareti
```

---

## ✅ Tam Örnek (Sizin Yapınıza Göre)

```swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            // 1. Bugün
            HomeView() // veya TodayView()
                .tabItem {
                    Label("Bugün", systemImage: "calendar")
                }
            
            // 2. Kıble (YENİ!)
            QiblaView()
                .tabItem {
                    Label("Kıble", systemImage: "location.north.fill")
                }
            
            // 3. İstatistik
            StatsView()
                .tabItem {
                    Label("İstatistik", systemImage: "chart.bar.fill")
                }
            
            // 4. Ayarlar
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

## 🚀 Test

1. Build: `⌘ + B`
2. Run: `⌘ + R`
3. Tab bar'da "Kıble" sekmesine bas
4. **Gerçek cihazda test et** (simülatörde pusula çalışmaz!)

---

## 📱 Beklenen Sonuç

Tab bar şöyle görünecek:

```
┌─────────┬─────────┬─────────┬─────────┐
│ 📅      │ 🧭      │ 📊      │ ⚙️      │
│ Bugün   │ Kıble   │ İstatistik│ Ayarlar │
└─────────┴─────────┴─────────┴─────────┘
```

Kıble sekmesine basınca:
- ✅ Koyu yeşil arkaplan
- ✅ Pusula görünecek
- ✅ Konum izni isteyecek (ilk kez)
- ✅ Ok Kıble yönüne dönecek

---

**ContentView.swift'i güncelleyin ve test edin!** 🎉
