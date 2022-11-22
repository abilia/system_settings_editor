import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class AuthenticatedDialogListener
    extends BlocListener<AuthenticatedDialogCubit, AuthenticatedDialogState> {
  AuthenticatedDialogListener({
    required AuthenticatedDialogCubit loginDialogCubit,
    Key? key,
  }) : super(
          key: key,
          listenWhen: (previous, current) =>
              previous is AuthenticatedDialogNotReady &&
              current is AuthenticatedDialogReady,
          listener: (context, _) {
            final authenticatedDialog = AuthenticatedDialog(
              loginDialogCubit: loginDialogCubit,
              showTermsOfUseDialog: loginDialogCubit.showTermsOfUseDialog,
              showStarterSetDialog: loginDialogCubit.showStarterSetDialog,
              showFullscreenAlarmDialog:
                  loginDialogCubit.showFullscreenAlarmDialog,
            );

            if (authenticatedDialog.numberOfDialogs > 0) {
              showViewDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => authenticatedDialog,
              );
            }
          },
        );
}
