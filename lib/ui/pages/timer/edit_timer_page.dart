import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class EditTimerPage extends StatelessWidget {
  const EditTimerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocListener<EditTimerCubit, EditTimerState>(
      listener: (context, state) {
        if (state is SavedTimerState) {
          return Navigator.pop(context, state.savedTimer);
        }
      },
      child: BlocBuilder<EditTimerCubit, EditTimerState>(
        builder: (context, state) => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar:
              AbiliaAppBar(iconData: AbiliaIcons.stopWatch, title: t.newTimer),
          body: Padding(
            padding: layout.templates.m3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const TimerNamePictureAndTimeWidget(),
                Expanded(
                  child: TimerWheel.interactive(
                    lengthInSeconds: state.duration.inSeconds,
                    onMinutesSelectedChanged: (minutesSelected) {
                      HapticFeedback.selectionClick();
                      context.read<EditTimerCubit>().updateDuration(
                            Duration(minutes: minutesSelected),
                          );
                    },
                  ).pad(layout.editTimer.wheelPadding),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: PreviousButton(
              onPressed: () => Navigator.pop(context),
            ),
            forwardNavigationWidget: StartButton(
              onPressed: state.duration.inMinutes > 0
                  ? context.read<EditTimerCubit>().start
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
      ),
    );
  }
}
