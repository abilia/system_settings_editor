import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class LoginDialogListener
    extends BlocListener<LoginDialogCubit, LoginDialogState> {
  LoginDialogListener({
    required LoginDialogCubit loginDialogCubit,
    Key? key,
  }) : super(
          key: key,
          listenWhen: (previous, current) =>
              previous is LoginDialogNotReady && current is LoginDialogReady,
          listener: (context, _) {
            final loginDialog = LoginDialog(
              loginDialogCubit: loginDialogCubit,
              showTermsOfUseDialog: loginDialogCubit.showTermsOfUseDialog,
              showStarterSetDialog: loginDialogCubit.showStarterSetDialog,
              showFullscreenAlarmDialog:
                  loginDialogCubit.showFullscreenAlarmDialog,
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
