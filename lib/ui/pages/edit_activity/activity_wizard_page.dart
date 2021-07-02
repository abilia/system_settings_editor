import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class ActivityWizardPage extends StatelessWidget {
  ActivityWizardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(
        initialPage: context.read<ActivityWizardCubit>().state.step);
    return BlocListener<ActivityWizardCubit, ActivityWizardState>(
      listener: (context, state) {
        pageController.animateToPage(state.step,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad);
      },
      child: PageView.builder(
          controller: pageController,
          itemBuilder: (context, index) {
            return BlocBuilder<ActivityWizardCubit, ActivityWizardState>(
              builder: (context, state) => Scaffold(
                appBar: AbiliaAppBar(
                  title: 'Title',
                  iconData: AbiliaIcons.about,
                ),
                body: Column(
                  children: [
                    Text('Tree wizard, tree wizard!'),
                    Spacer(),
                    BottomNavigation(
                      backNavigationWidget: CancelButton(
                        onPressed: () {
                          state.step == 0
                              ? Navigator.of(context).maybePop()
                              : context.read<ActivityWizardCubit>().previous();
                        },
                      ),
                      forwardNavigationWidget: NextButton(
                        onPressed: () {
                          context.read<ActivityWizardCubit>().next();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
