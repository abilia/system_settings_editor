import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seagull_logging/logging_levels_mixin.dart';

export 'package:permission_handler/permission_handler.dart';

part 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> with Info {
  PermissionCubit() : super(PermissionsUnchecked());

  Future<void> request(
    List<Permission> permissions,
  ) async {
    emit(
      state.update(await permissions.request()),
    );
  }

  Future<void> checkStatus(
    Iterable<Permission> permissions,
  ) async {
    emit(
      state.update(
        {for (final p in permissions) p: await p.status},
      ),
    );
  }

  Future<void> checkAll() => checkStatus(state.status.keys);
}
