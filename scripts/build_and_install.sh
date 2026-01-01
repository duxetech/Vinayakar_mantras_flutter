#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "1) Ensure device is connected"
adb devices -l

echo "2) Uninstall any existing app packages"
adb uninstall com.example.vinayagar_mantras || true
adb uninstall com.karthik.vinayagar_mantras || true

echo "3) Clean and get packages"
flutter clean
flutter pub get

echo "4) Build release APK"
flutter build apk --release -v

APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
  echo "5) Installing APK: $APK_PATH"
  adb install -r "$APK_PATH"
  echo "Installed OK"
else
  echo "ERROR: APK not found at $APK_PATH"
  exit 2
fi

echo "Done."