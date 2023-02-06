import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class AuthenticatedDialogListener
    extends BlocListener<AuthenticatedDialogCubit, AuthenticatedDialogState> {
  AuthenticatedDialogListener({
    required AuthenticatedDialogCubit authenticatedDialogCubit,
    Key? key,
  }) : super(
          key: key,
          listenWhen: (previous, current) => current.showDialog,
          listener: (context, state) => showPersistentDialog<bool>(
            context: context,
            builder: (context) => AuthenticatedDialog(
              authenticatedDialogCubit: authenticatedDialogCubit,
            ),
            routeSettings: (AuthenticatedDialog).routeSetting(),
          ),
        );
}
