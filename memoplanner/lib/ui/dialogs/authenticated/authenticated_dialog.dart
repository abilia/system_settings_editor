import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class AuthenticatedDialog extends StatelessWidget {
  final AuthenticatedDialogCubit authenticatedDialogCubit;

  const AuthenticatedDialog({
    required this.authenticatedDialogCubit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: authenticatedDialogCubit.state.numberOfDialogs,
      child: Builder(
        builder: (context) {
          return _AuthenticatedDialog(
            authenticatedDialogCubit: authenticatedDialogCubit,
            tabController: DefaultTabController.of(context),
          );
        },
      ),
    );
  }
}

class _AuthenticatedDialog extends StatelessWidget {
  final AuthenticatedDialogCubit authenticatedDialogCubit;
  final TabController? tabController;

  const _AuthenticatedDialog({
    required this.authenticatedDialogCubit,
    required this.tabController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginDialogState = authenticatedDialogCubit.state;

    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      controller: tabController,
      children: [
        if (loginDialogState.termsOfUse)
          TermsOfUseDialog(
            loginDialogCubit: authenticatedDialogCubit,
            isMoreDialogs: loginDialogState.numberOfDialogs > 1,
            onNext: () => onNext(context),
          ),
        if (loginDialogState.starterSet)
          StarterSetDialog(
            onNext: () => onNext(context),
          ),
        if (loginDialogState.fullscreenAlarm)
          FullscreenAlarmInfoDialog(
            showRedirect: true,
            onNext: () => onNext(context),
          ),
      ],
    );
  }

  void onNext(BuildContext context) {
    final currentIndex = tabController?.index;
    final lastIndex = authenticatedDialogCubit.state.numberOfDialogs - 1;
    if (currentIndex == lastIndex) {
      return Navigator.of(context).pop();
    }
    tabController?.index++;
  }
}
