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

  Widget get icon {
    switch (this) {
      case Permission.camera:
        return const Icon(
          AbiliaIcons.camera_photo,
          size: smallIconSize,
        );
      case Permission.photos:
      case Permission.storage:
        return const Icon(
          AbiliaIcons.camera_photo,
          size: smallIconSize,
        );
      case Permission.systemAlertWindow:
        return const Icon(
          AbiliaIcons.resize_higher,
          size: smallIconSize,
        );
      default:
        return const SizedBox(width: smallIconSize);
    }
  }
}

extension PermissionStatusExtension on PermissionStatus {
  bool get isDeniedOrPermenantlyDenied => isDenied || isPermanentlyDenied;
}
