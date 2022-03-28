import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class TimerDurationWiz extends StatelessWidget {
  const TimerDurationWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<TimerWizardCubit, TimerWizardState>(
      builder: (context, state) => Scaffold(
        appBar: AbiliaAppBar(iconData: AbiliaIcons.clock, title: t.setDuration),
        body: Padding(
          padding: layout.editTimer.inputTimePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: layout.editTimer.inputTimeWidth,
                child: TextField(
                  textAlign: TextAlign.center,
                  style: abiliaTextTheme.headline6,
                  controller:
                      TextEditingController(text: state.duration.toHMS()),
                  readOnly: true,
                  onTap: () async {
                    final authProviders = copiedAuthProviders(context);
                    final duration = await Navigator.of(context).push<Duration>(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: authProviders,
                          child: EditTimerByTypingPage(
                              initialDuration: state.duration),
                        ),
                      ),
                    );
                    if (duration != null) {
                      context.read<TimerWizardCubit>().updateDuration(duration);
                    }
                  },
                ),
              ),
              SizedBox(
                height: layout.editTimer.textToWheelDistance,
              ),
              Expanded(
                child: Padding(
                  padding: layout.templates.m4,
                  child: TimerWheel.interactive(
                    lengthInSeconds: state.duration.inSeconds,
                    onMinutesSelectedChanged: (minutesSelected) {
                      HapticFeedback.selectionClick();
                      context.read<TimerWizardCubit>().updateDuration(
                            Duration(minutes: minutesSelected),
                          );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget: PreviousButton(
            onPressed: context.read<TimerWizardCubit>().previous,
          ),
          forwardNavigationWidget: NextButton(
            onPressed: state.duration.inMinutes > 0
                ? context.read<TimerWizardCubit>().next
                : () => showViewDialog(
                      context: context,
                      builder: (context) => ErrorDialog(
                        text: Translator.of(context)
                            .translate
                            .timerInvalidDuration,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
