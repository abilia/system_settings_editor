import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class TimerPage extends StatelessWidget {
  final TimerOccasion timerOccasion;
  final DateTime day;

  const TimerPage({
    required this.timerOccasion,
    required this.day,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: abiliaWhiteTheme,
      child: BlocSelector<TimerAlarmBloc, TimerAlarmState, TimerOccasion>(
        selector: (timerState) => timerState.timers.firstWhere(
          (to) => to.timer.id == timerOccasion.timer.id,
          orElse: () => timerOccasion,
        ),
        builder: (context, timerOccasion) {
          final timer = timerOccasion.timer;
          return Scaffold(
            appBar: DayAppBar(day: day),
            body: Padding(
              padding: layout.templates.s1,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: borderRadius,
                  border: border,
                ),
                constraints: const BoxConstraints.expand(),
                child: Column(
                  children: <Widget>[
                    if (timer.hasTitle || timer.hasImage)
                      TimerTopInfo(timer: timer),
                    if (timer.hasTitle || timer.hasImage)
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
                                        Lt.of(context).timerPaused,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
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

class TimerTopInfo extends StatelessWidget {
  const TimerTopInfo({
    required this.timer,
    Key? key,
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
          mainAxisAlignment: MainAxisAlignment.center,
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
            if (timer.hasTitle)
              Expanded(
                child: Tts(
                  child: Text(
                    timer.title,
                    style: themeData.textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
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
    required this.timer,
    Key? key,
  }) : super(key: key);

  final AbiliaTimer timer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.navigationBar.height,
      child: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconActionButtonLight(
              onPressed: () async {
                final timerCubit = context.read<TimerCubit>();
                final navigator = Navigator.of(context);
                final confirmDeletion = await showViewDialog(
                  context: context,
                  builder: (context) => const DeleteTimerDialog(),
                  routeSettings: (DeleteTimerDialog).routeSetting(),
                );
                if (confirmDeletion) {
                  await timerCubit.deleteTimer(timer);
                  navigator.pop();
                }
              },
              child: const Icon(AbiliaIcons.deleteAllClear),
            ),
            IconActionButtonLight(
              onPressed: () async => Navigator.of(context).maybePop(),
              child: const Icon(AbiliaIcons.navigationPrevious),
            )
          ],
        ),
      ),
    );
  }
}

class DeleteTimerDialog extends StatelessWidget {
  const DeleteTimerDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return YesNoDialog(
      headingIcon: AbiliaIcons.deleteAllClear,
      heading: translate.delete,
      text: translate.timerDelete,
    );
  }
}
