import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/l10n/all.dart';
import 'package:memoplanner/ui/components/all.dart';
import 'package:memoplanner/ui/themes/all.dart';

final allPermissions = UnmodifiableSetView(
  {
    Permission.notification,
    Permission.microphone,
    if (Config.isMPGO && !Platform.isIOS) ...{
      Permission.systemAlertWindow,
      Permission.ignoreBatteryOptimizations,
    },
    if (!Platform.isAndroid) ...{
      Permission.photos,
      Permission.camera,
    }
  },
);

extension PermissionExtension on Permission {
  String translate(Lt translate) {
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

extension PermissionSateExtension on PermissionState {
  bool get notificationDenied =>
      status[Permission.notification]?.isDeniedOrPermanentlyDenied ?? false;

  bool get fullscreenNotGranted =>
      allPermissions.contains(Permission.systemAlertWindow) &&
      !(status[Permission.systemAlertWindow]?.isGranted ?? false);

  bool get importantPermissionMissing =>
      notificationDenied || fullscreenNotGranted;
}

extension PermissionStatusExtension on PermissionStatus {
  bool get isDeniedOrPermanentlyDenied => isDenied || isPermanentlyDenied;
}
