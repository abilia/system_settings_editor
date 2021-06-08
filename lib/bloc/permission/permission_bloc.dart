// @dart=2.9

import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:seagull/logging.dart';
import 'package:seagull/utils/all.dart';

export 'package:permission_handler/permission_handler.dart';

part 'permission_event.dart';
part 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> with Info {
  PermissionBloc() : super(PermissionState.empty());

  @override
  Stream<PermissionState> mapEventToState(
    PermissionEvent event,
  ) async* {
    if (event is RequestPermissions) {
      yield state.update(
        await event.permissions.request(),
      );
    }
    if (event is CheckStatusForPermissions) {
      yield state.update(
        {for (final p in event.permissions) p: await p.status},
      );
    }
  }

  static final allPermissions = UnmodifiableSetView(
    {
      Permission.notification,
      if (!Platform.isIOS) ...[
        Permission.systemAlertWindow,
        Permission.storage,
      ],
      if (!Platform.isAndroid) ...[
        Permission.photos,
        Permission.camera,
      ]
    },
  );

  void checkAll() => add(CheckStatusForPermissions(allPermissions.toList()));
}
