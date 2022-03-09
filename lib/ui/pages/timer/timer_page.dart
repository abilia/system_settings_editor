import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class TimerPage extends StatelessWidget {
  final TimerOccasion timerOccasion;
  final DateTime day;

  const TimerPage({
    Key? key,
    required this.timerOccasion,
    required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: abiliaWhiteTheme,
      child: BlocSelector<TimerAlarmBloc, TimerAlarmState, TimerOccasion>(
        selector: (timerState) => timerState.timers.firstWhere(
            (to) => to.timer.id == timerOccasion.timer.id,
            orElse: () => timerOccasion),
        builder: (context, timerOccasion) {
          final timer = timerOccasion.timer;
          return Scaffold(
            appBar: DayAppBar(day: day),
            body: Padding(
              padding: layout.timerPage.bodyPadding,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: borderRadius,
                  border: border,
                ),
                constraints: const BoxConstraints.expand(),
                child: Column(
                  children: <Widget>[
                    _TopInfo(timer: timer),
                    Divider(
                      height: layout.activityPage.dividerHeight,
                      endIndent: 0,
                      indent: layout.activityPage.dividerIndentation,
                    ),
                    Expanded(
                      child: Padding(
                        padding: layout.timerPage.mainContentPadding,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (timer.paused || !timerOccasion.isOngoing)
                              Expanded(
                                child: TimerWheel.nonInteractive(
                                  secondsLeft: timer.pausedAt.inSeconds,
                                  lengthInMinutes: timer.duration.inMinutes,
                                  paused: timer.paused,
                                ),
                              )
                            else
                              Expanded(
                                child: TimerTickerBuilder(
                                  timer,
                                  builder: (context, left) =>
                                      TimerWheel.nonInteractive(
                                    secondsLeft: left.inSeconds,
                                    lengthInMinutes: timer.duration.inMinutes,
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: layout.timerPage.pauseTextHeight,
                              child: timer.paused
                                  ? Tts(
                                      child: Text(
                                        Translator.of(context)
                                            .translate
                                            .timerPaused,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4
                                            ?.copyWith(
                                              color: AbiliaColors.red,
                                            ),
                                      ),
                                    )
                                  : null,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _TimerBottomBar(timer: timer),
          );
        },
      ),
    );
  }
}

class _TopInfo extends StatelessWidget {
  const _TopInfo({
    Key? key,
    required this.timer,
  }) : super(key: key);

  final AbiliaTimer timer;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return SizedBox(
      height: layout.timerPage.topInfoHeight,
      child: Padding(
        padding: layout.timerPage.topPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (timer.hasImage)
              Padding(
                padding: EdgeInsets.only(right: layout.timerPage.imagePadding),
                child: FadeInCalendarImage(
                  width: layout.timerPage.imageSize,
                  fit: BoxFit.cover,
                  imageFile: timer.image,
                ),
              ),
            Expanded(
              child: Tts(
                child: Text(
                  timer.title,
                  style: themeData.textTheme.headline5,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerBottomBar extends StatelessWidget {
  const _TimerBottomBar({
    Key? key,
    required this.timer,
  }) : super(key: key);

  final AbiliaTimer timer;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: layout.toolbar.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            if (timer.paused)
              PlayTimerButton(timer: timer)
            else
              PauseTimerButton(timer: timer),
            IconActionButtonLight(
              onPressed: () async {
                final t = Translator.of(context).translate;
                final confirmDeletion = await showViewDialog(
                  context: context,
                  builder: (context) => YesNoDialog(
                    headingIcon: AbiliaIcons.deleteAllClear,
                    heading: t.delete,
                    text: t.timerDelete,
                  ),
                );
                if (confirmDeletion) {
                  await context.read<TimerCubit>().deleteTimer(timer);
                  Navigator.pop(context);
                }
              },
              child: const Icon(AbiliaIcons.deleteAllClear),
            ),
            IconActionButtonLight(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Icon(AbiliaIcons.navigationPrevious),
            )
          ],
        ),
      ),
    );
  }
}

class PlayTimerButton extends StatelessWidget {
  const PlayTimerButton({
    Key? key,
    required this.timer,
  }) : super(key: key);

  final AbiliaTimer timer;

  @override
  Widget build(BuildContext context) => IconActionButton(
        style: actionButtonStyleLightSelected,
        onPressed: () async {
          final t = Translator.of(context).translate;
          final confirmPause = await showViewDialog<bool>(
            context: context,
            builder: (context) => YesNoDialog(
              headingIcon: AbiliaIcons.playSound,
              heading: t.resume,
              text: t.timerResume,
            ),
          );
          if (confirmPause == true) {
            await context.read<TimerCubit>().startTimer(timer);
          }
        },
        child: const Icon(AbiliaIcons.playSound),
      );
}

class PauseTimerButton extends StatelessWidget {
  const PauseTimerButton({
    Key? key,
    required this.timer,
  }) : super(key: key);

  final AbiliaTimer timer;

  @override
  Widget build(BuildContext context) => IconActionButtonLight(
        onPressed: () async {
          final t = Translator.of(context).translate;
          final confirmPause = await showViewDialog<bool>(
            context: context,
            builder: (context) => YesNoDialog(
              headingIcon: AbiliaIcons.pause,
              heading: t.pause,
              text: t.timerPause,
            ),
          );
          if (confirmPause == true) {
            await context.read<TimerCubit>().pauseTimer(timer);
          }
        },
        child: const Icon(AbiliaIcons.pause),
      );
}
