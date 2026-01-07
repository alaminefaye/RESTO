#!/bin/bash

# Script pour résoudre les problèmes de build Flutter/Android

echo "🧹 Nettoyage du projet Flutter..."

# Nettoyer Flutter
flutter clean

# Supprimer les caches Android
echo "🗑️  Suppression des caches Android..."
rm -rf android/.gradle
rm -rf android/build
rm -rf android/app/build
rm -rf android/.idea

# Supprimer les caches iOS (si sur Mac)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Nettoyage des caches iOS..."
    rm -rf ios/Pods
    rm -rf ios/.symlinks
    rm -rf ios/Flutter/Flutter.framework
    rm -rf ios/Flutter/Flutter.podspec
fi

# Réinstaller les dépendances
echo "📦 Réinstallation des dépendances..."
flutter pub get

# Si Android, nettoyer Gradle
if [ -d "android" ]; then
    echo "🔧 Nettoyage Gradle..."
    cd android
    ./gradlew clean 2>/dev/null || echo "Gradle non disponible"
    cd ..
fi

echo "✅ Nettoyage terminé ! Vous pouvez maintenant relancer l'application avec 'flutter run'"

