import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/duration.dart';

class TimerStartWiz extends StatelessWidget {
  const TimerStartWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<TimerWizardCubit, TimerWizardState>(
      builder: (context, state) => Scaffold(
        appBar:
            AbiliaAppBar(iconData: AbiliaIcons.stopWatch, title: t.startTimer),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(12.s, 24.s, 16.s, 20.s),
                child: const TimerNameAndPictureWidget()),
            const Divider(),
            Padding(
              padding: EdgeInsets.fromLTRB(12.s, 12.s, 16.s, 12.s),
              child: SizedBox(
                width: 119.s,
                child: Tts(
                  child: Text(state.duration.toHMS(),
                      textAlign: TextAlign.center,
                      style: abiliaTextTheme.headline6),
                ),
              ),
            ),
          ],
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
      ),
    );
  }
}
