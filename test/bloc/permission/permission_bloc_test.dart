import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/permission/permission_cubit.dart';

import '../../fakes/permission.dart';

void main() {
  setUp(TestWidgetsFlutterBinding.ensureInitialized);

  tearDown(() {
    checkedPermissions.clear();
    requestedPermissions.clear();
  });

  test('permission bloc initial state', () {
    final permissionCubit = PermissionCubit();
    expect(permissionCubit.state, PermissionState.empty());
    expect(permissionCubit.state.props, [{}]);
  });

  test('creating permission bloc does not call any permissions', () {
    setupPermissions();
    PermissionCubit();
    expect(checkedPermissions, isEmpty);
    expect(requestedPermissions, isEmpty);
  });

  test('requesting a permission requests the permission', () async {
    setupPermissions({Permission.camera: PermissionStatus.granted});
    final permissionCubit = PermissionCubit();
    permissionCubit.requestPermissions([Permission.camera]);
    await expectLater(
      permissionCubit.stream,
      emits(PermissionState.empty()
          .update({Permission.camera: PermissionStatus.granted})),
    );
    expect(requestedPermissions, contains(Permission.camera));
    expect(requestedPermissions, hasLength(1));
  });

  test('requesting multiple permission requests the permissions', () async {
    final permissonSet = {
      for (var key in PermissionCubit.allPermissions)
        key: PermissionStatus.granted
    };

    setupPermissions(permissonSet);
    final permissionCubit = PermissionCubit();
    permissionCubit.requestPermissions(permissonSet.keys.toList());
    await expectLater(
      permissionCubit.stream,
      emits(PermissionState.empty().update(permissonSet)),
    );
    expect(requestedPermissions, containsAll(permissonSet.keys));
    expect(requestedPermissions, hasLength(permissonSet.length));
  });

  test('checking a permission', () async {
    setupPermissions({Permission.camera: PermissionStatus.granted});
    final permissionCubit = PermissionCubit();
    permissionCubit.checkStatusForPermissions([Permission.camera]);
    await expectLater(
      permissionCubit.stream,
      emits(PermissionState.empty()
          .update({Permission.camera: PermissionStatus.granted})),
    );
    expect(checkedPermissions, contains(Permission.camera));
    expect(checkedPermissions, hasLength(1));
  });

  test('check multiple permissions', () async {
    final permissonSet = {
      for (var key in PermissionCubit.allPermissions)
        key: PermissionStatus.granted
    };
    setupPermissions(permissonSet);
    final permissionCubit = PermissionCubit();
    permissionCubit.checkStatusForPermissions(permissonSet.keys.toList());
    await expectLater(
      permissionCubit.stream,
      emits(PermissionState.empty().update(permissonSet)),
    );
    expect(checkedPermissions, containsAll(permissonSet.keys));
    expect(checkedPermissions, hasLength(permissonSet.length));
  });

  group('PermissionState conditional updates', () {
    test('a permanentlyDenied permission will not change to denied', () async {
      final permissionState = PermissionState.empty()
          .update({Permission.camera: PermissionStatus.permanentlyDenied});

      final result =
          permissionState.update({Permission.camera: PermissionStatus.denied});
      expect(result.status,
          {Permission.camera: PermissionStatus.permanentlyDenied});
    });

    test('a granted permission will change to denied', () async {
      final permissionState = PermissionState.empty()
          .update({Permission.camera: PermissionStatus.granted});
      final result =
          permissionState.update({Permission.camera: PermissionStatus.denied});
      expect(result.status, {Permission.camera: PermissionStatus.denied});
    });

    test('a denied permission will return denied', () async {
      final permissionState = PermissionState.empty()
          .update({Permission.camera: PermissionStatus.denied});
      final result =
          permissionState.update({Permission.camera: PermissionStatus.denied});
      expect(result.status, {Permission.camera: PermissionStatus.denied});
    });
  });
}
