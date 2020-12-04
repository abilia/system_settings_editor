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


if [ "$release" ]
  then
    echo "Building APK"
    flutter build apk --release --build-number=$APPCENTER_BUILD_ID --dart-define=release=$release
    # copy the APK where AppCenter will find it
    mkdir -p android/app/build/outputs/apk/; mv build/app/outputs/apk/release/app-release.apk $_memoplannergo-$APPCENTER_BUILD_ID-$release.apk
  else
    echo "Building AAB"
    flutter build appbundle --build-number=$APPCENTER_BUILD_ID
    # copy the AAB where AppCenter will find it
    mkdir -p android/app/build/outputs/bundle/; mv build/app/outputs/bundle/release/app-release.aab $_memoplannergo-$APPCENTER_BUILD_ID.aab
fi
