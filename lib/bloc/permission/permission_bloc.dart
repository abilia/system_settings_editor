import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seagull/logging.dart';

export 'package:permission_handler/permission_handler.dart';

part 'permission_event.dart';
part 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> with Shout {
  PermissionBloc() : super(PermissionState.empty());

  @override
  Stream<PermissionState> mapEventToState(
    PermissionEvent event,
  ) async* {
    if (event is RequestPermissions) {
      yield state._update(
        await event.permissions.request(),
      );
    }
    if (event is CheckStatusForPermissions) {
      yield state._update(
        await {for (final p in event.permissions) p: await p.status},
      );
    }
  }

  static const allPermissions = [
    Permission.notification,
    Permission.camera,
    Permission.photos,
  ];
  void checkAll() => add(const CheckStatusForPermissions(allPermissions));
}
