import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';

extension PermissionExtension on Permission {
  String translate(Translated translate) {
    switch (this) {
      case Permission.camera:
        return translate.accessToCamera;
      case Permission.photos:
        return translate.accessToPhotos;
      case Permission.notification:
        return translate.notifications;
      default:
        return '';
    }
  }
}

extension PermissionStatusExtension on PermissionStatus {
  bool get isGrantedOrUndetermined =>
      this == null || isGranted || isUndetermined;
}
