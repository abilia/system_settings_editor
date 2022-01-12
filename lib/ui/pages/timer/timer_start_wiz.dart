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
                padding: EdgeInsets.fromLTRB(12.s, 24.s, 16.s, 20.s),
                child: const TimerNameAndPictureWidget()),
            const Divider(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.s, 12.s, 16.s, 12.s),
                child: Container(
                  decoration: BoxDecoration(
                    color: AbiliaColors.white,
                    borderRadius: borderRadius,
                    border: Border.all(color: AbiliaColors.white140),
                  ),
                  constraints: const BoxConstraints.expand(),
                  child: TimerWheel.nonInteractive(
                      activeSeconds: state.duration.inSeconds),
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
