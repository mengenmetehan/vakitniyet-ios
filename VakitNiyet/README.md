# 🕌 VakitNiyet

Namaz vakitleri ve günlük Kuran ayeti bildirimleri içeren iOS uygulaması.

## ✨ Özellikler

- 📍 **Konum Bazlı Namaz Vakitleri**: Bulunduğunuz konuma göre günlük namaz vakitlerini görüntüleyin
- 🔔 **Akıllı Bildirimler**: Namaz vakti yaklaştığında otomatik bildirim alın
- 📖 **Günlük Ayet**: Her gün farklı bir Kuran ayeti ile bilgilendirilme
- 🎯 **Hedef Takibi**: Namaz kılma hedeflerinizi takip edin ve streak oluşturun
- 🌙 **Modern UI**: Temiz ve kullanıcı dostu arayüz
- ☁️ **Senkronizasyon**: Apple Sign In ile cihazlar arası senkronizasyon
- 🔒 **Gizlilik**: Verileriniz güvende, Apple'ın gizlilik standartlarına uygun

## 🛠 Teknolojiler

- **Swift & SwiftUI**: Modern iOS geliştirme
- **UserNotifications**: Local ve push bildirimleri
- **CoreLocation**: Konum bazlı namaz vakitleri
- **Sign in with Apple**: Güvenli kimlik doğrulama
- **URLSession**: RESTful API entegrasyonu
- **Combine**: Reactive programlama

## 📱 Gereksinimler

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## 🚀 Kurulum

### Hızlı Başlangıç

```bash
# 1. Klonla
git clone https://github.com/[kullaniciadi]/VakitNiyet.git
cd VakitNiyet

# 2. .env dosyalarını oluştur
cp .env.example .env.development
cp .env.example .env.production

# 3. .env.development dosyasını düzenle
vim .env.development
# BASE_URL=http://localhost:3000/v1/api

# 4. Xcode'da aç
open VakitNiyet.xcodeproj
```

### Xcode'da Yapılacaklar

1. **`.env.development` dosyasını projeye ekle:**
   - VakitNiyet klasörüne sağ tık
   - Add Files to "VakitNiyet"
   - `.env.development` seç
   - ✅ "Copy items if needed" işaretle
   - Add

2. **Run:**
   ```
   ⌘ + R
   ```

### 🔄 URL Değiştirme (Ngrok vb.)

`.env.development` dosyasını düzenleyin:
```bash
BASE_URL=http://your-ngrok-url.ngrok-free.app/v1/api
```

Kaydedin ve uygulamayı yeniden başlatın (⌘R)

📖 **Detaylı rehber:** [ENV_RUNTIME_GUIDE.md](ENV_RUNTIME_GUIDE.md)

## 🔧 Yapılandırma

### Backend API

Uygulama şu endpointleri kullanır:

- `POST /auth/apple/signin` - Apple ile giriş
- `GET /prayer-times` - Namaz vakitleri
- `POST /notification/device-token` - Bildirim token güncelleme
- `POST /notification/test-send` - Test bildirimi
- `GET /prayer-history` - Namaz geçmişi
- `POST /prayer-history` - Namaz kaydı

### Bildirimler

Bildirim özellikleri için:
1. Xcode > Signing & Capabilities
2. "+ Capability" butonuna tıklayın
3. "Push Notifications" ekleyin

## 📂 Proje Yapısı

```
VakitNiyet/
├── App/
│   ├── VakitNiyetApp.swift
│   └── AppDelegate.swift
├── Core/
│   ├── Services/
│   │   ├── AuthService.swift
│   │   ├── NetworkService.swift
│   │   ├── LocationService.swift
│   │   └── NotificationManager.swift
│   ├── Models/
│   └── Utilities/
├── Features/
│   ├── Auth/
│   │   └── SignInView.swift
│   ├── Home/
│   │   └── ContentView.swift
│   ├── PrayerTimes/
│   └── Settings/
│       └── SettingsView.swift
└── Resources/
    └── Assets.xcassets
```

## 🎨 Ekran Görüntüleri

_(Ekran görüntüleri eklenecek)_

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 👨‍💻 Geliştirici

**Metehan Mengen**

## 🙏 Teşekkürler

- Namaz vakitleri API'si
- Kuran ayetleri veritabanı
- Apple geliştirici topluluğu

## 📞 İletişim

Sorularınız veya önerileriniz için issue açabilirsiniz.

---

⭐️ Bu projeyi faydalı bulduysanız yıldız vermeyi unutmayın!
