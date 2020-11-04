import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/permission/permission_bloc.dart';

import '../../mocks.dart';

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
  });
  tearDown(() {
    checkedPermissions.clear();
    requestedPermissions.clear();
  });

  test('permission bloc initial state', () {
    final permissionBloc = PermissionBloc();
    expect(permissionBloc.state, PermissionState.empty());
    expect(permissionBloc.state.props, [{}]);
  });

  test('creating permission bloc does not call any permissions', () {
    setupPermissions();
    PermissionBloc();
    expect(checkedPermissions, isEmpty);
    expect(requestedPermissions, isEmpty);
  });

  test('requesting a permission requests the permission', () async {
    setupPermissions({Permission.camera: PermissionStatus.granted});
    final permissionBloc = PermissionBloc();
    permissionBloc.add(RequestPermissions([Permission.camera]));
    await expectLater(
      permissionBloc,
      emits(PermissionState.empty()
          .update({Permission.camera: PermissionStatus.granted})),
    );
    expect(requestedPermissions, contains(Permission.camera));
    expect(requestedPermissions, hasLength(1));
  });

  test('requesting multiple permission requests the permissions', () async {
    final permissonSet = {
      for (var key in PermissionBloc.allPermissions)
        key: PermissionStatus.granted
    };

    setupPermissions(permissonSet);
    final permissionBloc = PermissionBloc();
    permissionBloc.add(RequestPermissions(permissonSet.keys.toList()));
    await expectLater(
      permissionBloc,
      emits(PermissionState.empty().update(permissonSet)),
    );
    expect(requestedPermissions, containsAll(permissonSet.keys));
    expect(requestedPermissions, hasLength(permissonSet.length));
  });

  test('checking a permission', () async {
    setupPermissions({Permission.camera: PermissionStatus.granted});
    final permissionBloc = PermissionBloc();
    permissionBloc.add(CheckStatusForPermissions([Permission.camera]));
    await expectLater(
      permissionBloc,
      emits(PermissionState.empty()
          .update({Permission.camera: PermissionStatus.granted})),
    );
    expect(checkedPermissions, contains(Permission.camera));
    expect(checkedPermissions, hasLength(1));
  });

  test('check multiple permissions', () async {
    final permissonSet = {
      for (var key in PermissionBloc.allPermissions)
        key: PermissionStatus.granted
    };
    setupPermissions(permissonSet);
    final permissionBloc = PermissionBloc();
    permissionBloc.add(CheckStatusForPermissions(permissonSet.keys.toList()));
    await expectLater(
      permissionBloc,
      emits(PermissionState.empty().update(permissonSet)),
    );
    expect(checkedPermissions, containsAll(permissonSet.keys));
    expect(checkedPermissions, hasLength(permissonSet.length));
  });
}