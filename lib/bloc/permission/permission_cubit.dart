import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seagull/config.dart';

import 'package:seagull/logging.dart';
import 'package:seagull/utils/all.dart';

export 'package:permission_handler/permission_handler.dart';

part 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> with Info {
  PermissionCubit() : super(PermissionState.empty());

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

  void checkAll() => checkStatusForPermissions(allPermissions);
}
