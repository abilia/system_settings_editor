import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class FullscreenAlarmPermissionListener
    extends BlocListener<PermissionCubit, PermissionState> {
  FullscreenAlarmPermissionListener({Key? key})
      : super(
          key: key,
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
}
