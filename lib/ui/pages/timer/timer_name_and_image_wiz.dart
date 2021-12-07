import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TimerNameAndImageWiz extends StatelessWidget {
  const TimerNameAndImageWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.about,
        title: 'Start timer',
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: PreviousButton(
          onPressed: () {
            context.read<TimerWizardCubit>().next();
          },
        ),
        forwardNavigationWidget: StartButton(
          onPressed: () {
            context.read<TimerWizardCubit>().next();
          },
        ),
      ),
    );
  }
}
