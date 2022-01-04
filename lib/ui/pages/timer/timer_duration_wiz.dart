import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/duration.dart';

class TimerDurationWiz extends StatelessWidget {
  const TimerDurationWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(iconData: AbiliaIcons.clock, title: t.setDuration),
      body: BlocBuilder<TimerWizardCubit, TimerWizardState>(
        builder: (context, state) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 36.s),
              child: SizedBox(
                width: 119.s,
                child: TextField(
                  textAlign: TextAlign.center,
                  style: abiliaTextTheme.headline6,
                  controller:
                      TextEditingController(text: state.duration.toHMS()),
                  readOnly: true,
                  onTap: () async {
                    final duration = await Navigator.of(context).push<Duration>(
                      MaterialPageRoute(
                        builder: (_) => CopiedAuthProviders(
                          blocContext: context,
                          child: EditTimerByTypingPage(
                              initialDuration: state.duration),
                        ),
                      ),
                    );
                    if (duration != null) {
                      context.read<TimerWizardCubit>().updateDuration(duration);
                      context.read<TimerWizardCubit>().updateName(duration
                          .toDurationString(Translator.of(context).translate,
                              shortMin: false));
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 26.s),
                child: TimerWheel.interactive(
                  activeSeconds: state.duration.inSeconds,
                  onMinutesSelectedChanged: (minutesSelected) {
                    HapticFeedback.selectionClick();
                    context.read<TimerWizardCubit>().updateDuration(
                          Duration(minutes: minutesSelected),
                        );
                    context.read<TimerWizardCubit>().updateName(
                        Duration(minutes: minutesSelected).toDurationString(
                            Translator.of(context).translate,
                            shortMin: false));
                  },
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: PreviousButton(
          onPressed: () async {
            await Navigator.of(context).maybePop();
            context.read<TimerWizardCubit>().previous();
          },
        ),
        forwardNavigationWidget: NextButton(
          onPressed: () {
            context.read<TimerWizardCubit>().next();
          },
        ),
      ),
    );
  }
}