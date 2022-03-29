import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.permissions,
        label: translate.system,
        iconData: AbiliaIcons.menuSetup,
      ),
      body: BlocBuilder<PermissionCubit, PermissionState>(
        builder: (context, state) => ListView(
          padding: layout.templates.m1,
          children: state.status.entries
              .where((p) => PermissionCubit.allPermissions.contains(p.key))
              .map((e) => PermissionSetting(e))
              .expand((e) => [
                    e,
                    SizedBox(height: layout.formPadding.verticalItemDistance),
                  ])
              .toList(),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(
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
    Key? key,
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
    Key? key,
    required this.permission,
    required this.status,
  }) : super(key: key);

  final Permission permission;
  final PermissionStatus status;

  @override
  Widget build(BuildContext context) {
    return SwitchField(
      key: ObjectKey(permission),
      leading: permission.icon,
      value: status.isGranted,
      onChanged: (v) async {
        if (status.isPermanentlyDenied || status.isGranted) {
          await openAppSettings();
          return;
        }
        context.read<PermissionCubit>().requestPermissions([permission]);
      },
      child: Text(permission.translate(Translator.of(context).translate)),
    );
  }
}

class NotificationPermissionSwitch extends StatelessWidget {
  final permission = Permission.notification;
  final PermissionStatus status;

  const NotificationPermissionSwitch({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final denied = status.isDeniedOrPermenantlyDenied;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SwitchField(
              key: ObjectKey(permission),
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
                        const NotificationPermissionOffWarningDialog(
                      onOk: openAppSettings,
                    ),
                  );
                } else {
                  context
                      .read<PermissionCubit>()
                      .requestPermissions([permission]);
                }
              },
              child: Text(permission.translate(translate)),
            ),
            if (denied)
              Positioned(
                right: layout.permissionsPage.deniedDotPosition,
                top: layout.permissionsPage.deniedDotPosition,
                child: Container(
                  width: layout.permissionsPage.deniedContainerSize,
                  height: layout.permissionsPage.deniedContainerSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        layout.permissionsPage.deniedBorderRadius,
                      ),
                    ),
                    color: AbiliaColors.orange40,
                  ),
                  child: Icon(
                    AbiliaIcons.irError,
                    size: layout.icon.tiny,
                  ),
                ),
              ),
          ],
        ),
        if (denied)
          Padding(
            padding: layout.permissionsPage.deniedPadding,
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
    Key? key,
    required this.status,
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
                clipBehavior: Clip.none,
                children: [
                  SwitchField(
                    key: ObjectKey(permission),
                    leading: permission.icon,
                    value: status.isGranted,
                    decoration:
                        denied ? warningBoxDecoration : whiteBoxDecoration,
                    onChanged: (v) async {
                      if (status.isGranted) {
                        await showViewDialog(
                          context: context,
                          builder: (context) =>
                              const NotificationPermissionOffWarningDialog(
                            onOk: AndroidIntents.openSystemAlertSetting,
                          ),
                        );
                      } else {
                        context
                            .read<PermissionCubit>()
                            .requestPermissions([Permission.systemAlertWindow]);
                      }
                    },
                    child: Text(permission.translate(translate)),
                  ),
                  if (denied)
                    Positioned(
                      right: layout.permissionsPage.deniedDotPosition,
                      top: layout.permissionsPage.deniedDotPosition,
                      child: Container(
                        width: layout.permissionsPage.deniedContainerSize,
                        height: layout.permissionsPage.deniedContainerSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(
                              layout.permissionsPage.deniedBorderRadius)),
                          color: AbiliaColors.orange40,
                        ),
                        child: Icon(
                          AbiliaIcons.irError,
                          size: layout.icon.tiny,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: layout.formPadding.horizontalItemDistance,
              ),
              child: InfoButton(
                onTap: () => showViewDialog(
                  context: context,
                  builder: (context) => const FullscreenAlarmInfoDialog(),
                ),
              ),
            ),
          ],
        ),
        if (denied) ...[
          Padding(
            padding: layout.permissionsPage.deniedVerticalPadding,
            child: ErrorMessage(
              text: Text(translate.fullScreenAlarmInfo),
            ),
          ),
          Tts(
            child: Text(
              translate.redirectToAndroidSettings,
              style: Theme.of(context).textTheme.caption?.copyWith(
                    color: AbiliaColors.black75,
                  ),
            ),
          )
        ]
      ],
    );
  }
}
