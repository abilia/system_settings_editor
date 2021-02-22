#!/bin/bash
# Simple script for installing Memoplanner and locking the device to memoplanner. 
# Requires the device to be open to connections through adb, developer mode.
# Also need adb to be setup on computer running the script.

set -e
APK="mp.apk"

echo Starting
# Add -t with test-only flag.
adb install $APK

# Sets application as device owner
adb shell dpm set-device-owner com.abilia.memoplanner/.DeviceAdminReceiver
# Starts the application after install. Needed for the next step
adb shell am start -W -n com.abilia.memoplanner/.MainActivity
# Starts the service which locks the device to the application
adb shell am startservice -n com.abilia.memoplanner/.LockService

echo Done
