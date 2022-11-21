import 'package:flutter/foundation.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class LoginDialogListener
    extends BlocListener<LoginDialogCubit, LoginDialogState> {
  LoginDialogListener({
    required LoginDialogCubit loginDialogCubit,
    required SortableBloc sortableBloc,
    required PermissionCubit permissionCubit,
    Key? key,
  }) : super(
          key: key,
          listenWhen: (previous, current) =>
              previous is LoginDialogNotReady && current is LoginDialogReady,
          listener: (context, state) {
            final showTermsOfUseDialog = !state.termsOfUse.allAccepted;

            final sortableState = sortableBloc.state;
            final showStarterSetDialog = sortableState is SortablesLoaded &&
                sortableState.sortables.isEmpty;

            final isAndroid = defaultTargetPlatform == TargetPlatform.android;
            final fullscreenAlarmEnabled = Config.isMPGO && isAndroid;
            final permissionStatus = permissionCubit.state.status;
            final showFullscreenAlarmDialog = fullscreenAlarmEnabled &&
                permissionStatus.containsKey(Permission.systemAlertWindow) &&
                !(permissionStatus[Permission.systemAlertWindow]?.isGranted ??
                    false);

            final loginDialog = LoginDialog(
              loginDialogCubit: loginDialogCubit,
              showTermsOfUseDialog: showTermsOfUseDialog,
              showStarterSetDialog: showStarterSetDialog,
              showFullscreenAlarmDialog: showFullscreenAlarmDialog,
            );

            if (loginDialog.numberOfDialogs > 0) {
              showViewDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => loginDialog,
              );
            }
          },
        );
}
