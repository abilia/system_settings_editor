// https://github.com/Baseflow/flutter-permission-handler/issues/262#issuecomment-702691396
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

const _methodChannelName = 'flutter.baseflow.com/permissions/methods';
Set<Permission> checkedPermissions = {};
Set<Permission> requestedPermissions = {};
Map<Permission, PermissionStatus> _permissions = const {};
int openAppSettingsCalls = 0;

Future _handler(MethodCall methodCall) async {
  switch (methodCall.method) {
    case 'requestPermissions':
      requestedPermissions.addAll(
        (methodCall.arguments as List)
            .cast<int>()
            .map((i) => Permission.values[i]),
      );
      return _permissions
          .map((key, value) => MapEntry<int, int>(key.value, value.value));
    case 'checkPermissionStatus':
      final askedPermission = Permission.values[methodCall.arguments as int];
      checkedPermissions.add(askedPermission);
      return (_permissions[askedPermission])?.value ??
          PermissionStatus.granted.index;
    case 'openAppSettings':
      openAppSettingsCalls++;
      break;
  }
  return null;
}

void setupPermissions(
    [Map<Permission, PermissionStatus> permissions = const {}]) {
  checkedPermissions = {};
  requestedPermissions = {};
  openAppSettingsCalls = 0;
  _permissions = permissions;

  if (TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
          .checkMockMessageHandler(_methodChannelName, _handler) ==
      false) {
    const MethodChannel(_methodChannelName).setMockMethodCallHandler(_handler);
  }
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
