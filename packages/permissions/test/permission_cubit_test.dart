import 'package:flutter_test/flutter_test.dart';
import 'package:permissions/permission_cubit.dart';

import 'fakes/permissions.dart';

final allPermissions = {
  Permission.notification,
  Permission.microphone,
  Permission.systemAlertWindow,
  Permission.ignoreBatteryOptimizations,
  Permission.photos,
  Permission.camera,
};

void main() {
  setUp(TestWidgetsFlutterBinding.ensureInitialized);

  tearDown(() {
    checkedPermissions.clear();
    requestedPermissions.clear();
  });

  test('initial state', () {
    final permissionCubit = PermissionCubit();
    expect(permissionCubit.state, PermissionsUnchecked());
    expect(permissionCubit.state.props, [{}]);
  });

  test('creating cubit does not call any permissions', () {
    setupPermissions();
    PermissionCubit();
    expect(checkedPermissions, isEmpty);
    expect(requestedPermissions, isEmpty);
  });

  test('requesting a permission requests the permission', () async {
    setupPermissions({Permission.camera: PermissionStatus.granted});
    final permissionCubit = PermissionCubit()..request([Permission.camera]);
    await expectLater(
      permissionCubit.stream,
      emits(PermissionsUnchecked()
          .update({Permission.camera: PermissionStatus.granted})),
    );
    expect(requestedPermissions, contains(Permission.camera));
    expect(requestedPermissions, hasLength(1));
  });

  test('requesting multiple permission requests the permissions', () async {
    final permissionSet = {
      for (var key in allPermissions) key: PermissionStatus.granted
    };

    setupPermissions(permissionSet);
    final permissionCubit = PermissionCubit()
      ..request(permissionSet.keys.toList());
    await expectLater(
      permissionCubit.stream,
      emits(PermissionsUnchecked().update(permissionSet)),
    );
    expect(requestedPermissions, containsAll(permissionSet.keys));
    expect(requestedPermissions, hasLength(permissionSet.length));
  });

  test('checking a permission', () async {
    setupPermissions({Permission.camera: PermissionStatus.granted});
    final permissionCubit = PermissionCubit()..checkStatus([Permission.camera]);
    await expectLater(
      permissionCubit.stream,
      emits(PermissionsUnchecked()
          .update({Permission.camera: PermissionStatus.granted})),
    );
    expect(checkedPermissions, contains(Permission.camera));
    expect(checkedPermissions, hasLength(1));
  });

  test('check multiple permissions', () async {
    final permissionSet = {
      for (var key in allPermissions) key: PermissionStatus.granted
    };
    setupPermissions(permissionSet);
    final permissionCubit = PermissionCubit()
      ..checkStatus(permissionSet.keys.toList());
    await expectLater(
      permissionCubit.stream,
      emits(PermissionsUnchecked().update(permissionSet)),
    );
    expect(checkedPermissions, containsAll(permissionSet.keys));
    expect(checkedPermissions, hasLength(permissionSet.length));
  });

  group('PermissionState conditional updates', () {
    test('a permanentlyDenied permission will not change to denied', () async {
      final permissionState = PermissionsUnchecked()
          .update({Permission.camera: PermissionStatus.permanentlyDenied});

      final result =
          permissionState.update({Permission.camera: PermissionStatus.denied});
      expect(result.status,
          {Permission.camera: PermissionStatus.permanentlyDenied});
    });

    test('a granted permission will change to denied', () async {
      final permissionState = PermissionsUnchecked()
          .update({Permission.camera: PermissionStatus.granted});
      final result =
          permissionState.update({Permission.camera: PermissionStatus.denied});
      expect(result.status, {Permission.camera: PermissionStatus.denied});
    });

    test('a denied permission will return denied', () async {
      final permissionState = PermissionsUnchecked()
          .update({Permission.camera: PermissionStatus.denied});
      final result =
          permissionState.update({Permission.camera: PermissionStatus.denied});
      expect(result.status, {Permission.camera: PermissionStatus.denied});
    });
  });
}
