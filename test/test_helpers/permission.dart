// https://github.com/Baseflow/flutter-permission-handler/issues/262#issuecomment-702691396
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

Set<Permission> checkedPermissions = {};
Set<Permission> requestedPermissions = {};
int openAppSettingsCalls = 0;
void setupPermissions(
    [Map<Permission, PermissionStatus> permissions = const {}]) {
  checkedPermissions = {};
  requestedPermissions = {};
  openAppSettingsCalls = 0;
  MethodChannel('flutter.baseflow.com/permissions/methods')
      .setMockMethodCallHandler(
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'requestPermissions':
          requestedPermissions.addAll(
            (methodCall.arguments as List)
                .cast<int>()
                .map((i) => Permission.values[i]),
          );
          return permissions
              .map((key, value) => MapEntry<int, int>(key.value, value.value));
        case 'checkPermissionStatus':
          final askedPermission =
              Permission.values[methodCall.arguments as int];
          checkedPermissions.add(askedPermission);
          return (permissions[askedPermission])?.value ??
              PermissionStatus.granted.index;
        case 'openAppSettings':
          openAppSettingsCalls++;
          break;
      }
    },
  );
}

extension PermissionStatusValue on PermissionStatus {
  int get value {
    switch (this) {
      case PermissionStatus.denied:
        return 0;
      case PermissionStatus.granted:
        return 1;
      case PermissionStatus.restricted:
        return 2;
      case PermissionStatus.limited:
        return 3;
      case PermissionStatus.permanentlyDenied:
        return 4;
      default:
        return 3;
    }
  }
}
