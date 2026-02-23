#!/bin/bash
echo "Cloning Flutter repository..."
git clone https://github.com/flutter/flutter.git -b stable

echo "Adding Flutter to PATH..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "Running flutter pub get..."
flutter pub get

echo "Building Flutter web..."
flutter build web --release
