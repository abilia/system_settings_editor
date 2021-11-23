import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/themes/all.dart';

extension PermissionExtension on Permission {
  String translate(Translated translate) {
    if (this == Permission.camera) return translate.accessToCamera;
    if (this == Permission.notification) return translate.notifications;
    if (this == Permission.systemAlertWindow) return translate.fullScreenAlarm;
    if (this == Permission.photos) return translate.accessToPhotos;
    if (this == Permission.microphone) return translate.accessToMicrophone;
    return toString();
  }

  Widget get icon => Icon(
        iconData,
        size: layout.iconSize.small,
      );

  IconData get iconData {
    if (this == Permission.camera) return AbiliaIcons.cameraPhoto;
    if (this == Permission.systemAlertWindow) return AbiliaIcons.resizeHigher;
    if (this == Permission.notification) return AbiliaIcons.notification;
    if (this == Permission.photos) return AbiliaIcons.upload;
    if (this == Permission.microphone) return AbiliaIcons.dictaphone;
    if (this == Permission.location) return AbiliaIcons.gewaRadio;
    return AbiliaIcons.empty1;
  }
}

extension PermissionStatusExtension on PermissionStatus {
  bool get isDeniedOrPermenantlyDenied => isDenied || isPermanentlyDenied;
}
