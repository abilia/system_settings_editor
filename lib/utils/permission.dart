import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

extension PermissionExtension on Permission {
  String translate(Translated translate) {
    switch (this) {
      case Permission.camera:
        return translate.accessToCamera;
      case Permission.photos:
      case Permission.storage:
        return translate.accessToPhotos;
      case Permission.notification:
        return translate.notifications;
      case Permission.systemAlertWindow:
        return translate.fullScreenAlarm;
      default:
        return toString();
    }
  }

  Widget get icon => Icon(
        iconData,
        size: smallIconSize,
      );

  IconData get iconData {
    switch (this) {
      case Permission.camera:
        return AbiliaIcons.camera_photo;
      case Permission.photos:
      case Permission.storage:
        return AbiliaIcons.my_photos;
      case Permission.systemAlertWindow:
        return AbiliaIcons.resize_higher;
      case Permission.notification:
        return AbiliaIcons.notification;
      default:
        return AbiliaIcons.empty1;
    }
  }
}

extension PermissionStatusExtension on PermissionStatus {
  bool get isDeniedOrPermenantlyDenied => isDenied || isPermanentlyDenied;
  bool get isGrantedOrUndetermined =>
      this == null || isGranted || isUndetermined;
}
