#!/bin/bash

# Environment Variables Build Script
# Bu script .env dosyasından değerleri okuyup GeneratedConfig.swift oluşturur

set -e

# Build configuration'a göre .env dosyasını seç
if [ "${CONFIGURATION}" = "Debug" ]; then
    ENV_FILE="${SRCROOT}/.env.development"
else
    ENV_FILE="${SRCROOT}/.env.production"
fi

# .env dosyası yoksa hata ver
if [ ! -f "$ENV_FILE" ]; then
    echo "error: .env dosyası bulunamadı: $ENV_FILE"
    echo "error: Lütfen .env.example dosyasını kopyalayıp düzenleyin"
    exit 1
fi

# Output dosyası
OUTPUT_FILE="${SRCROOT}/VakitNiyet/Generated/GeneratedConfig.swift"

# Generated klasörünü oluştur
mkdir -p "${SRCROOT}/VakitNiyet/Generated"

# .env dosyasını oku
source "$ENV_FILE"

# GeneratedConfig.swift dosyasını oluştur
cat > "$OUTPUT_FILE" << EOF
//
// GeneratedConfig.swift
// VakitNiyet
//
// Bu dosya otomatik olarak build sırasında oluşturulur.
// DOĞRUDAN DÜZENLEME YAPMAYIN!
// .env.development veya .env.production dosyalarını düzenleyin.
//

import Foundation

enum GeneratedConfig {
    static let baseURL = "${BASE_URL}"
}
EOF

echo "✅ GeneratedConfig.swift oluşturuldu: $OUTPUT_FILE"
echo "📍 Kullanılan .env dosyası: $ENV_FILE"
echo "🔗 BASE_URL: ${BASE_URL}"
