#!/usr/bin/env bash
#Place this script in project/android/app/

cd ..

# fail if any command fails
set -e
# debug log
set -x

cd ..
git clone -b beta https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH

flutter channel stable
flutter doctor

echo "Installed flutter to `pwd`/flutter"

# run tests
flutter test

echo "Building APK"
flutter build apk --flavor $flavor --release --build-number=$APPCENTER_BUILD_ID --dart-define=release=$release
# copy the APK where AppCenter will find it
mkdir -p android/app/build/outputs/apk/; mv build/app/outputs/flutter-apk/app-$flavor-release.apk $_/$flavor-$APPCENTER_BUILD_ID-$release.apk

if [ "$APPCENTER_BRANCH" = "release" ]; then
  echo "Building AAB"
  flutter build appbundle --flavor $flavor --build-number=$APPCENTER_BUILD_ID
  # copy the AAB where AppCenter will find it
  mkdir -p android/app/build/outputs/bundle/; mv build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab $_/$flavor-$APPCENTER_BUILD_ID.aab
fi
