import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';

class PermissionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.permissions,
        closeIcon: AbiliaIcons.navigation_previous,
      ),
      body: BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 20.0, 16.0, 0),
          child: Column(
            children: state.status.entries
                .map((e) => PermissionSwitch(e))
                .expand((e) => [e, const SizedBox(height: 12.0)])
                .toList(),
          ),
        ),
      ),
    );
  }
}

class PermissionSwitch extends StatelessWidget {
  final Permission permission;
  final PermissionStatus status;

  PermissionSwitch(
    MapEntry<Permission, PermissionStatus> entry, {
    Key key,
  })  : permission = entry.key,
        status = entry.value,
        super(key: key);

  @override
  Widget build(BuildContext context) => permission == Permission.notification
      ? NotificationPermissionSwitch(status: status)
      : SwitchField(
          key: ObjectKey(permission),
          text: Text(permission.translate(Translator.of(context).translate)),
          leading: permission.icon,
          value: status.isGranted,
          onChanged: (v) async {
            if (status.isPermanentlyDenied || status.isGranted) {
              await openAppSettings();
              return;
            }
            context
                .bloc<PermissionBloc>()
                .add(RequestPermissions([permission]));
          },
        );
}

class NotificationPermissionSwitch extends StatelessWidget {
  final permission = Permission.notification;
  final PermissionStatus status;

  const NotificationPermissionSwitch({
    Key key,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final denied = status.isDeniedOrPermenantlyDenied;
    return Column(
      children: [
        Stack(
          overflow: Overflow.visible,
          children: [
            SwitchField(
              key: ObjectKey(permission),
              text: Text(translate.notifications),
              leading: SizedBox(width: smallIconSize),
              value: status.isGranted,
              decoration: denied ? warningBoxDecoration : whiteBoxDecoration,
              onChanged: (v) async {
                if (denied) {
                  await openAppSettings();
                } else if (status.isGranted) {
                  await showViewDialog(
                    context: context,
                    builder: (context) =>
                        NotificationPermissionOffWarningDialog(),
                  );
                } else {
                  context
                      .bloc<PermissionBloc>()
                      .add(RequestPermissions([permission]));
                }
              },
            ),
            if (denied)
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    color: AbiliaColors.orange40,
                  ),
                  child: Icon(
                    AbiliaIcons.ir_error,
                    size: 20.0,
                  ),
                ),
              ),
          ],
        ),
        if (denied)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: ErrorMessage(
              text: Text(translate.notificationsWarningHintText),
            ),
          )
      ],
    );
  }
}
