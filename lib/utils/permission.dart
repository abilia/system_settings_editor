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
    if (this == Permission.photos || this == Permission.storage) {
      return translate.accessToPhotos;
    }

    return toString();
  }

  Widget get icon => Icon(
        iconData,
        size: smallIconSize,
      );

  IconData get iconData {
    if (this == Permission.camera) return AbiliaIcons.camera_photo;
    if (this == Permission.systemAlertWindow) return AbiliaIcons.resize_higher;
    if (this == Permission.notification) return AbiliaIcons.notification;
    if (this == Permission.photos || this == Permission.storage) {
      return AbiliaIcons.upload;
    }
    return AbiliaIcons.empty1;
  }
}

extension PermissionStatusExtension on PermissionStatus {
  bool get isDeniedOrPermenantlyDenied => isDenied || isPermanentlyDenied;
}
