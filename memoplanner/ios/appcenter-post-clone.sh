#!/usr/bin/env bash

# Set environment variable for API key
ABILIA_OPEN_API_KEY=${{ secrets.DEVICE_API_KEY }}

# Fail if any command fails
set -e
# Debug log
set -x

# Navigate to project root
cd ..

# Install Flutter
FLUTTER_VERSION=3.10.2
git clone --depth 1 --branch $FLUTTER_VERSION https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH
echo "Installed Flutter version $FLUTTER_VERSION to `pwd`/flutter"

# Install CocoaPods
pod setup

# Create .env file
touch ./lib/env/.env.key
echo "ABILIA_OPEN_API_KEY=$ABILIA_OPEN_API_KEY" > ./lib/env/.env.key

# Run Flutter commands
flutter doctor
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
flutter build ios --release --no-codesign --build-number=$APPCENTER_BUILD_ID --dart-define=release=$release
