import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:intent/flag.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:meta/meta.dart';
import 'package:package_info/package_info.dart';
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

  static Future openSystemAlertSetting() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final intent = android_intent.Intent()
      ..setAction('android.settings.action.MANAGE_OVERLAY_PERMISSION')
      ..setData(Uri(scheme: 'package', path: packageInfo.packageName))
      ..addFlag(Flag.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
    await intent.startActivity();
  }
}
