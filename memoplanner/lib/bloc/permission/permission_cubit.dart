import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seagull_logging/logging_levels_mixin.dart';

export 'package:permission_handler/permission_handler.dart';

part 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> with Info {
  PermissionCubit() : super(PermissionsUnchecked());

  Future<void> requestPermissions(
    List<Permission> permissions,
  ) async {
    emit(
      state.update(await permissions.request()),
    );
  }

  Future<void> checkStatusForPermissions(
    Iterable<Permission> permissions,
  ) async {
    emit(
      state.update(
        {for (final p in permissions) p: await p.status},
      ),
    );
  }

  static final allPermissions = UnmodifiableSetView(
    {
      Permission.notification,
      Permission.microphone,
      if (Config.isMPGO && !Platform.isIOS) ...{
        Permission.systemAlertWindow,
      },
      if (!Platform.isAndroid) ...{
        Permission.photos,
        Permission.camera,
      }
    },
  );

  Future<void> checkAllAndRequestPermissions(
    List<Permission> permissions,
  ) async {
    await checkAll();
    return requestPermissions(permissions);
  }

  Future<void> checkAll() => checkStatusForPermissions(allPermissions);
}
