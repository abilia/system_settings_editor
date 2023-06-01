import 'package:flutter/material.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/i18n/all.dart';
import 'package:memoplanner/ui/components/all.dart';
import 'package:memoplanner/ui/themes/all.dart';

extension PermissionExtension on Permission {
  String translate(Translated translate) {
    if (this == Permission.camera) return translate.accessToCamera;
    if (this == Permission.notification) return translate.notifications;
    if (this == Permission.systemAlertWindow) return translate.fullScreenAlarm;
    if (this == Permission.photos) return translate.accessToPhotos;
    if (this == Permission.microphone) return translate.accessToMicrophone;
    if (this == Permission.ignoreBatteryOptimizations) {
      return translate.ignoreBatteryOptimizations;
    }
    return toString();
  }

  Widget get icon => Icon(
        iconData,
        size: layout.icon.small,
      );

  IconData get iconData {
    if (this == Permission.camera) return AbiliaIcons.cameraPhoto;
    if (this == Permission.systemAlertWindow) return AbiliaIcons.resizeHigher;
    if (this == Permission.notification) return AbiliaIcons.notification;
    if (this == Permission.photos) return AbiliaIcons.upload;
    if (this == Permission.microphone) return AbiliaIcons.dictaphone;
    if (this == Permission.location) return AbiliaIcons.gewaRadio;
    if (this == Permission.ignoreBatteryOptimizations) {
      return AbiliaIcons.batteryLevelWarning;
    }
    return AbiliaIcons.quickSettings;
  }
}

extension PermissionStatusExtension on PermissionStatus {
  bool get isDeniedOrPermanentlyDenied => isDenied || isPermanentlyDenied;
}
