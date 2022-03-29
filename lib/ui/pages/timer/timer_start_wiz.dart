import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

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
                padding: layout.templates.m3,
                child: const TimerNameAndPictureWidget()),
            const Divider(),
            Expanded(
              child: Padding(
                padding: layout.templates.s1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AbiliaColors.white,
                    borderRadius: borderRadius,
                    border: Border.all(color: AbiliaColors.white140),
                  ),
                  constraints: const BoxConstraints.expand(),
                  child: TimerWheel.nonInteractive(
                    secondsLeft: state.duration.inSeconds,
                    lengthInMinutes: state.duration.inMinutes,
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget: PreviousButton(
            onPressed: context.read<TimerWizardCubit>().previous,
          ),
          forwardNavigationWidget: StartButton(
            onPressed: context.read<TimerWizardCubit>().next,
          ),
        ),
      ),
    );
  }
}
