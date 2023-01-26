#!/usr/bin/env bash
#Place this script in project/ios/

# fail if any command fails
set -e
# debug log
set -x

cd ..
git clone --depth 1 --branch 3.7.0 https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH

pod setup
flutter doctor

echo "Installed flutter to `pwd`/flutter"

flutter test

flutter build ios --release --no-codesign --build-number=$APPCENTER_BUILD_ID --dart-define=release=$release
