#!/usr/bin/env bash
#Place this script in project/ios/

# fail if any command fails
set -e
# debug log
set -x

cd ..
git clone -b beta https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH

flutter channel stable
sudo gem uninstall cocoapods
sudo gem install cocoapods -v 1.10.0
pod setup
flutter doctor

echo "Installed flutter to `pwd`/flutter"

flutter test

flutter build ios --release --no-codesign --build-name=$(date "+%Y.%m.%d") --build-number=$APPCENTER_BUILD_ID --dart-define=release=$release
