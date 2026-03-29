# Qibla View Integration Guide

## Adding Qibla to ContentView

### Option 1: As a Tab in TabView

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Prayer Times
            PrayerTimesView()
                .tabItem {
                    Label("Vakitler", systemImage: "clock")
                }
            
            // Qibla
            QiblaView()
                .tabItem {
                    Label("Kıble", systemImage: "location.north.fill")
                }
            
            // Settings
            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape")
                }
        }
        .accentColor(Color(hex: "1B4332"))
    }
}
```

### Option 2: As a Button/Sheet

```swift
struct PrayerTimesView: View {
    @State private var showQibla = false
    
    var body: some View {
        NavigationView {
            VStack {
                // ... prayer times content
                
                Button(action: {
                    showQibla = true
                }) {
                    HStack {
                        Image(systemName: "location.north.fill")
                        Text("Kıble Yönü")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "1B4332"))
                    .cornerRadius(12)
                }
                .padding()
            }
            .sheet(isPresented: $showQibla) {
                QiblaView()
            }
        }
    }
}
```

### Option 3: As Navigation Link

```swift
NavigationLink(destination: QiblaView()) {
    HStack {
        Image(systemName: "location.north.fill")
            .foregroundColor(Color(hex: "1B4332"))
        
        Text("Kıble Yönü")
            .font(.headline)
        
        Spacer()
        
        Image(systemName: "chevron.right")
            .foregroundColor(.gray)
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    .shadow(radius: 2)
}
```

## Quick Integration Steps:

1. **Add to existing TabView** (if you have one)
2. **Or create new navigation** to QiblaView
3. **Update color scheme** to match your app
4. **Test on real device** (compass doesn't work on simulator)

## Color Consistency:

Make sure to use the same green color throughout:
```swift
Color(hex: "1B4332") // Primary dark green
Color(hex: "2D6A4F") // Secondary green
Color(hex: "0D1F16") // Dark background
```

## Example: Full ContentView with Qibla

```swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
            
            QiblaView()
                .tabItem {
                    Label("Kıble", systemImage: "location.north.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
        }
        .accentColor(Color(hex: "1B4332"))
    }
}
```

## Testing Checklist:

- [ ] Info.plist permissions added
- [ ] Build successful
- [ ] Tested on real device
- [ ] Location permission granted
- [ ] Compass updates smoothly
- [ ] Arrow points correctly
- [ ] Calibration warning shows when needed
- [ ] UI looks clean and spiritual

Enjoy your Qibla feature! 🕌
