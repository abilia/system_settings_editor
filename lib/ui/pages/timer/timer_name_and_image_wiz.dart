import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TimerNameAndImageWiz extends StatelessWidget {
  const TimerNameAndImageWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.stopWatch,
        title: t.startTimer,
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: PreviousButton(
          onPressed: () {
            context.read<TimerWizardCubit>().previous();
          },
        ),
        forwardNavigationWidget: StartButton(
          onPressed: () {
            context.read<TimerWizardCubit>().next();
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }
}
