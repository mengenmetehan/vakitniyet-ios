# Vakit Niyet - Backend Entegrasyon Rehberi

## 📋 Genel Bakış

Backend API entegrasyonu tamamlanmıştır. Swagger dökümantasyonuna göre tüm endpoint'ler implement edilmiştir.

## 🔐 Authentication Flow

### 1. Apple Sign In
- **Endpoint**: `POST /api/auth/apple`
- **Dosyalar**: 
  - `AuthService.swift` - Sign in yönetimi
  - `SignInView.swift` - UI
- **Akış**:
  1. Kullanıcı "Sign in with Apple" butonuna tıklar
  2. Apple'dan identity token ve authorization code alınır
  3. Backend'e gönderilir
  4. Access token + Refresh token alınır
  5. Token'lar `UserDefaults` ve `NetworkService` actor'ında saklanır

### 2. Token Management
- **Access Token**: Her request'te Bearer token olarak gönderilir
- **Refresh Token**: Access token expire olduğunda yenilenir
- **Auto Refresh**: 401 hatası geldiğinde otomatik refresh yapılır

### 3. Device Token (Push Notifications)
- **Endpoint**: `PUT /api/auth/device-token`
- **Dosyalar**:
  - `NotificationManager.swift`
  - `AppDelegate.swift`
- **Akış**:
  1. Uygulama açıldığında notification permission istenir
  2. iOS'tan device token alınır
  3. Backend'e gönderilir
  4. Backend bu token'ı kullanarak push notification gönderir

## 📡 API Endpoints

### Prayer Endpoints

```swift
// Bugünün namazları
GET /api/prayer/today
→ DayResponse { date, prayers[], doneCount }

// Belirli gün
GET /api/prayer/day/{date}
→ DayResponse

// Aylık kayıtlar
GET /api/prayer/month?year=2026&month=3
→ MonthResponse { days[] }

// Namaz toggle
POST /api/prayer/toggle
Body: { prayerName: "Sabah", date?: "2026-03-28" }
→ PrayerLogResponse { prayerName, date, isDone, prayedAt? }

// Diyanet vakitleri
GET /api/prayer/times/today?ilceId=9541
→ PrayerTimesResponse { imsak, gunes, ogle, ikindi, aksam, yatsi }

// Streak
GET /api/prayer/streak
→ StreakResponse { currentStreak, longestStreak, lastFullDay? }

// İstatistikler
GET /api/prayer/stats
→ StatsResponse { streak, thisMonthTotal, thisMonthDays, completionRate, mostMissed? }
```

### Location Endpoints (Public)

```swift
// Ülkeler
GET /api/public/location/countries
→ DiyanetUlke[] { UlkeID, UlkeAdi }

// Şehirler
GET /api/public/location/cities?ulkeId=2
→ DiyanetSehir[] { SehirID, SehirAdi }

// İlçeler
GET /api/public/location/districts?ilId=34
→ DiyanetIlce[] { IlceID, IlceAdi }
```

### Notification Settings

```swift
// Ayarları al
GET /api/notification/settings
→ NotificationSettingsResponse

// Ayarları güncelle
PUT /api/notification/settings
Body: { 
  enabled?: bool, 
  ilceId?: string,
  offsetMinutes?: int,
  contentType?: string,
  fajrEnabled?: bool,
  dhuhrEnabled?: bool,
  asrEnabled?: bool,
  maghribEnabled?: bool,
  ishaEnabled?: bool
}
→ NotificationSettingsResponse
```

### Subscription

```swift
// Durum sorgula
GET /api/subscription/status
→ SubscriptionStatusResponse { plan, status, isActive, trialDaysLeft?, currentPeriodEnd? }

// Receipt doğrula
POST /api/subscription/verify
Body: { receiptData: string, productId: string }
→ SubscriptionStatusResponse
```

## 🏗️ Mimari

### Network Layer
- **NetworkService.swift** (Actor)
  - Thread-safe token management
  - Generic request fonksiyonu
  - Automatic token refresh
  - Error handling

### API Service
- **PrayerAPIService.swift**
  - Tüm API endpoint'leri
  - Type-safe requests
  - Date formatting

### Data Flow

```
UI (SwiftUI View)
    ↓
PrayerStore (ObservableObject)
    ↓
PrayerAPIService
    ↓
NetworkService (Actor)
    ↓
URLSession
    ↓
Backend API
```

## 🔔 Push Notifications

### Setup Checklist

1. **Xcode Capability**
   - Signing & Capabilities → Push Notifications ekleyin
   - Background Modes → Remote notifications aktif edin

2. **Apple Developer Portal**
   - APNs key oluşturun
   - Backend'e key'i ekleyin

3. **Backend**
   - Device token'ları saklıyor
   - Namaz vaktine göre scheduled notification gönderiyor
   - Content type'a göre (hadis/ayet/karma) içerik oluşturuyor

### Notification Flow

```
1. Uygulama açılır
   ↓
2. NotificationManager.requestPermission()
   ↓
3. iOS device token verir
   ↓
4. Backend'e PUT /api/auth/device-token
   ↓
5. Kullanıcı location ve settings ayarlar
   ↓
6. Backend PUT /api/notification/settings ile kaydeder
   ↓
7. Backend her gün namaz vaktine göre notification schedule eder
   ↓
8. Notification gelir → Kullanıcı tıklar → Uygulama açılır
```

## 📱 Kullanıcı Akışı

### İlk Açılış
1. Sign in with Apple ekranı
2. Apple hesabı seçimi
3. Backend'e kayıt
4. Ana ekrana yönlendirme
5. Location seçimi (Diyanet vakitleri için)
6. Notification permission

### Günlük Kullanım
1. Uygulama açılır
2. `PrayerStore.init()` → Backend'den bugünün verileri çekilir
3. Kullanıcı namaz işaretler
4. Optimistic update + Backend sync
5. Streak güncellenir

### Ayarlar
1. Location değiştirme → Yeni vakitler çekilir
2. Notification ayarları → Backend'e kaydedilir
3. Prayer-specific toggles → Backend'e kaydedilir

## 🛠️ Geliştirme Notları

### Base URL
```swift
// NetworkService.swift
private let baseURL = "https://raggedy-recklessly-jaelyn.ngrok-free.dev/v1/api"

// Local development için:
// private let baseURL = "http://localhost:8080/v1/api"

// Production için:
// private let baseURL = "https://api.vakitniyet.app/v1/api"
```

**Test URL'leri:**
- Backend API: `https://raggedy-recklessly-jaelyn.ngrok-free.dev/v1/api`
- Swagger UI: `https://raggedy-recklessly-jaelyn.ngrok-free.dev/v1/swagger-ui/index.html`

### Mock Data Fallback
`PrayerStore.swift` içinde `loadMockData()` fonksiyonu var. Backend erişilemediğinde UI geliştirmesi yapılabilir.

### Prayer Name Mapping
Backend'in kullandığı namaz isim formatına göre `mapPrayerNameToAPI()` fonksiyonu güncellenebilir:
- Şu an: "Sabah", "Öğle", "İkindi", "Akşam", "Yatsı"
- Alternatif: "fajr", "dhuhr", "asr", "maghrib", "isha"

### Error Handling
- Network hataları `errorMessage` @Published property'sine kaydedilir
- UI'da gösterilmek üzere `PrayerStore` içinde saklanır
- Optimistic updates revert edilir

## 🧪 Test Senaryoları

### 1. Sign In
- [ ] Apple Sign In başarılı
- [ ] Token'lar kaydediliyor
- [ ] Ana ekrana yönleniyor

### 2. Prayer Toggle
- [ ] Toggle çalışıyor
- [ ] Backend'e kaydediliyor
- [ ] Streak güncelleniyor
- [ ] Month view güncelleniy or

### 3. Location
- [ ] Ülke listesi geliyor
- [ ] Şehir listesi geliyor
- [ ] İlçe listesi geliyor
- [ ] Seçim kaydediliyor
- [ ] Vakitler güncelleniyor

### 4. Notifications
- [ ] Permission isteniyor
- [ ] Device token backend'e gidiyor
- [ ] Settings kaydediliyor
- [ ] Test notification çalışıyor

### 5. Subscription
- [ ] Status çekiliyor
- [ ] Trial bilgisi gösteriliyor
- [ ] Receipt verification çalışıyor

## 📝 TODO

- [ ] Production base URL environment variable olarak ayarla
- [ ] Keychain kullanarak token'ları daha güvenli sakla
- [ ] Offline mode - Local database (CoreData/SwiftData)
- [ ] Background refresh - Günlük vakitleri otomatik güncelle
- [ ] Widget extension - Home screen widget
- [ ] Watch app - watchOS companion
- [ ] Share extension - Arkadaşlara davet
- [ ] StoreKit 2 - In-app purchase entegrasyonu

## 🔗 İlgili Dosyalar

### Core
- `PrayerStore.swift` - Ana state management
- `NetworkService.swift` - Network layer
- `PrayerAPIService.swift` - API endpoints

### Auth
- `AuthService.swift` - Authentication yönetimi
- `SignInView.swift` - Sign in UI
- `AppState.swift` - Global app state

### Notifications
- `NotificationManager.swift` - Push notification yönetimi
- `AppDelegate.swift` - Remote notification delegates

### UI
- `SettingsView.swift` - Ayarlar ekranı
- `LocationPickerView.swift` - Konum seçimi
- `HomeView.swift` - Ana ekran
- `StatsView.swift` - İstatistikler

### Models
- `Models.swift` - UI modelleri (Prayer, PrayerName, MonthDayRecord)
- `NetworkService.swift` - API response/request modelleri

## 🚀 Deploy Checklist

1. Base URL'i production'a değiştir
2. APNs key ekle
3. Code signing ayarla
4. Privacy policy URL'ini güncelle
5. App Store Connect'te in-app purchase ürünlerini oluştur
6. TestFlight beta test
7. App Store submission

---

**Son Güncelleme**: 28 Mart 2026
**Backend API Versiyonu**: v1
**iOS Minimum**: iOS 17.0
