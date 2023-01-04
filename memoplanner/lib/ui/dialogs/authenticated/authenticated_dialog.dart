import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class AuthenticatedDialog extends StatelessWidget {
  final AuthenticatedDialogCubit authenticatedDialogCubit;

  const AuthenticatedDialog({
    required this.authenticatedDialogCubit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginDialogState = authenticatedDialogCubit.state;
    final pageController = PageController();

    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (loginDialogState.termsOfUse)
          TermsOfUseDialog(
            loginDialogCubit: authenticatedDialogCubit,
            isMoreDialogs: loginDialogState.numberOfDialogs > 1,
            onNext: () => _onNext(context, pageController),
          ),
        if (loginDialogState.starterSet)
          StarterSetDialog(
            onNext: () => _onNext(context, pageController),
          ),
        if (loginDialogState.fullscreenAlarm)
          FullscreenAlarmInfoDialog(
            showRedirect: true,
            onNext: () => _onNext(context, pageController),
          ),
      ],
    );
  }

  void _onNext(BuildContext context, PageController pageController) {
    final currentIndex = pageController.page?.toInt();
    final lastIndex = authenticatedDialogCubit.state.numberOfDialogs - 1;
    if (currentIndex == lastIndex) {
      return Navigator.of(context).pop();
    }
    _nextPage(pageController);
  }

  void _nextPage(PageController pageController) {
    pageController.nextPage(
      duration: 500.milliseconds(),
      curve: Curves.easeOutQuad,
    );
  }
}
