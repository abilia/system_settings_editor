import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class FullscreenAlarmPremissionListener
    extends BlocListener<PermissionCubit, PermissionState> {
  FullscreenAlarmPremissionListener({Key? key})
      : super(
          key: key,
          listener: (context, state) async {
            BlocListener<PermissionCubit, PermissionState>(
              listenWhen: (previous, current) =>
                  !previous.status.containsKey(Permission.systemAlertWindow) &&
                  current.status.containsKey(Permission.systemAlertWindow) &&
                  !(current.status[Permission.systemAlertWindow]?.isGranted ??
                      false),
              listener: (context, state) => showViewDialog(
                context: context,
                builder: (context) => const FullscreenAlarmInfoDialog(
                  showRedirect: true,
                ),
              ),
            );
          },
        );
}
