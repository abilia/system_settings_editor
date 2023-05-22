import 'package:get_it/get_it.dart';
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

    return TrackablePageView(
      controller: pageController,
      analytics: GetIt.I<SeagullAnalytics>(),
      children: [
        if (loginDialogState.termsOfUse)
          TermsOfUseDialog(
            loginDialogCubit: authenticatedDialogCubit,
            isMoreDialogs: loginDialogState.numberOfDialogs > 1,
            onNext: () async => _onNext(context, pageController),
          ),
        if (loginDialogState.starterSet)
          StarterSetDialog(
            onNext: () async => _onNext(context, pageController),
          ),
        if (loginDialogState.fullscreenAlarm)
          const FullscreenAlarmInfoDialog(showRedirect: true),
      ],
    );
  }

  Future<void> _onNext(
      BuildContext context, PageController pageController) async {
    if (!pageController.hasClients) return;
    final currentIndex = pageController.page?.toInt();
    final lastIndex = authenticatedDialogCubit.state.numberOfDialogs - 1;
    if (currentIndex == lastIndex) {
      return Navigator.of(context).pop();
    }
    await _nextPage(pageController);
  }

  Future<void> _nextPage(PageController pageController) =>
      pageController.nextPage(
        duration: 500.milliseconds(),
        curve: Curves.easeOutQuad,
      );
}
