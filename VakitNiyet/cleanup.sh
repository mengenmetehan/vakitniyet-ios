#!/bin/bash

# Gereksiz dosyaları temizleme scripti

echo "🧹 Gereksiz dosyaları temizliyoruz..."

# Gereksiz döküman dosyaları
FILES_TO_REMOVE=(
    "SETUP_COMPLETE.md"
    "CLEANUP.md"
    "QUICKSTART.md"
    "XCCONFIG_SETUP.md"
    "Configurations/Config.debug.xcconfig"
    "Configurations/Config.release.xcconfig"
    "Configurations/Config.example.xcconfig"
    "Config.debug.xcconfig"
    "Config.release.xcconfig"
    "Config.example.xcconfig"
    "Scripts/generate-config.sh"
    "VakitNiyet/Info.plist"
)

for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$file" ]; then
        echo "🗑️  Siliniyor: $file"
        rm "$file"
    elif [ -d "$file" ]; then
        echo "🗑️  Klasör siliniyor: $file"
        rm -rf "$file"
    fi
done

# Boş klasörleri temizle
if [ -d "Configurations" ] && [ -z "$(ls -A Configurations)" ]; then
    echo "🗑️  Boş klasör siliniyor: Configurations"
    rm -rf "Configurations"
fi

if [ -d "Scripts" ] && [ -z "$(ls -A Scripts)" ]; then
    echo "🗑️  Boş klasör siliniyor: Scripts"
    rm -rf "Scripts"
fi

echo ""
echo "✅ Temizlik tamamlandı!"
echo ""
echo "📁 Kalan dosyalar:"
echo "  ✅ .env.example"
echo "  ✅ .env.development (local - Git'e eklenmemeli)"
echo "  ✅ .env.production (local - Git'e eklenmemeli)"
echo "  ✅ EnvironmentLoader.swift"
echo "  ✅ AppConfig.swift"
echo "  ✅ ENV_SETUP.md"
echo "  ✅ ENV_RUNTIME_GUIDE.md"
echo "  ✅ .gitignore"
echo ""
echo "🎯 Sistem: Runtime .env okuma"
echo ""
