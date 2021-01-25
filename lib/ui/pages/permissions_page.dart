import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class PermissionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: NewAbiliaAppBar(
        title: translate.permissions,
        iconData: AbiliaIcons.menu_setup,
      ),
      body: BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 20.0, 16.0, 0),
          child: ListView(
            children: state.status.entries
                .map((e) => PermissionSetting(e))
                .expand((e) => [e, const SizedBox(height: 12.0)])
                .toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: PreviousButton(),
      ),
    );
  }
}

class PermissionSetting extends StatelessWidget {
  final Permission permission;
  final PermissionStatus status;

  PermissionSetting(
    MapEntry<Permission, PermissionStatus> entry, {
    Key key,
  })  : permission = entry.key,
        status = entry.value,
        super(key: key);

  @override
  Widget build(BuildContext context) => permission == Permission.notification
      ? NotificationPermissionSwitch(status: status)
      : permission == Permission.systemAlertWindow
          ? FullscreenPermissionSwitch(status: status)
          : PermissionSwitch(permission: permission, status: status);
}

class PermissionSwitch extends StatelessWidget {
  const PermissionSwitch({
    Key key,
    @required this.permission,
    @required this.status,
  }) : super(key: key);

  final Permission permission;
  final PermissionStatus status;

  @override
  Widget build(BuildContext context) {
    return SwitchField(
      key: ObjectKey(permission),
      text: Text(permission.translate(Translator.of(context).translate)),
      leading: permission.icon,
      value: status.isGranted,
      onChanged: (v) async {
        if (status.isPermanentlyDenied || status.isGranted) {
          await openAppSettings();
          return;
        }
        context.read<PermissionBloc>().add(RequestPermissions([permission]));
      },
    );
  }
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
              text: Text(permission.translate(translate)),
              leading: permission.icon,
              value: status.isGranted,
              decoration: denied ? warningBoxDecoration : whiteBoxDecoration,
              onChanged: (v) async {
                if (denied) {
                  await openAppSettings();
                } else if (status.isGranted) {
                  await showViewDialog(
                    context: context,
                    builder: (context) =>
                        NotificationPermissionOffWarningDialog(
                      onOk: openAppSettings,
                    ),
                  );
                } else {
                  context
                      .read<PermissionBloc>()
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
          ),
      ],
    );
  }
}

class FullscreenPermissionSwitch extends StatelessWidget {
  final permission = Permission.systemAlertWindow;
  final PermissionStatus status;

  const FullscreenPermissionSwitch({
    Key key,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final denied = status.isDeniedOrPermenantlyDenied;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Stack(
                overflow: Overflow.visible,
                children: [
                  SwitchField(
                    key: ObjectKey(permission),
                    text: Text(permission.translate(translate)),
                    leading: permission.icon,
                    value: status.isGranted,
                    decoration:
                        denied ? warningBoxDecoration : whiteBoxDecoration,
                    onChanged: (v) async {
                      if (status.isGranted) {
                        await showViewDialog(
                          context: context,
                          builder: (context) =>
                              NotificationPermissionOffWarningDialog(
                            onOk: openSystemAlertSetting,
                          ),
                        );
                      } else {
                        await openSystemAlertSetting();
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
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: InfoButton(
                onTap: () => showViewDialog(
                  context: context,
                  builder: (context) => FullscreenAlarmInfoDialog(),
                ),
              ),
            ),
          ],
        ),
        if (denied) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ErrorMessage(
              text: Text(translate.notificationsWarningHintText),
            ),
          ),
          Tts(
            child: Text(
              translate.redirectToAndroidSettings,
              style: Theme.of(context).textTheme.caption.copyWith(
                    color: AbiliaColors.black75,
                  ),
            ),
          )
        ]
      ],
    );
  }
}
