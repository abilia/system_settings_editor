#!/usr/bin/env bash

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

# Run Flutter commands
flutter doctor
flutter pub get
flutter test
flutter build ios --release --no-codesign --build-number=$APPCENTER_BUILD_ID
