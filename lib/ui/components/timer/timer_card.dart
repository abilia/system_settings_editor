import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class TimerCard extends StatelessWidget {
  final TimerOccasion timerOccasion;
  final DateTime day;
  const TimerCard({
    Key? key,
    required this.timerOccasion,
    required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPast = timerOccasion.isPast;
    final textTheme = abiliaTheme.textTheme;
    final themeData = isPast
        ? abiliaTheme.copyWith(
            textTheme: textTheme.copyWith(
              bodyText1:
                  textTheme.bodyText1?.copyWith(color: AbiliaColors.white140),
            ),
            iconTheme:
                abiliaTheme.iconTheme.copyWith(color: AbiliaColors.white140))
        : abiliaTheme;
    return AnimatedTheme(
      duration: ActivityCard.duration,
      data: themeData,
      child: Builder(
        builder: (context) => Tts.fromSemantics(
          timerOccasion.timer.semanticsProperties(context),
          child: Container(
            height: layout.eventCard.height,
            decoration: getCategoryBoxDecoration(
              current: timerOccasion.isOngoing,
              inactive: isPast,
              category: timerOccasion.category,
              showCategoryColor: false,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: borderRadius - BorderRadius.circular(2.0),
                onTap: () {
                  final authProviders = copiedAuthProviders(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MultiBlocProvider(
                        providers: authProviders,
                        child: TimerPage(
                          timerOccasion: timerOccasion,
                          day: day,
                        ),
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    if (isPast || timerOccasion.timer.hasImage)
                      Padding(
                        padding: layout.eventCard.imagePadding,
                        child: SizedBox(
                          width: layout.eventCard.imageSize,
                          child: EventImage.fromEventOccasion(
                            eventOccasion: timerOccasion,
                            fit: BoxFit.cover,
                            crossPadding: layout.eventCard.crossPadding,
                            crossOverColor: AbiliaColors.transparentBlack30,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: layout.eventCard.titlePadding,
                        child: Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                timerOccasion.timer.title,
                                style: Theme.of(context).textTheme.subtitle1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TimeLeft(timerOccasion),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: layout.eventCard.timerWheelPadding,
                      child: SizedBox(
                        width: layout.eventCard.timerWheelSize,
                        child: TimerCardWheel(timerOccasion),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TimeLeft extends StatelessWidget {
  final TimerOccasion timerOccasion;
  const TimeLeft(this.timerOccasion, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText1 ?? bodyText1,
      overflow: TextOverflow.ellipsis,
      child: timerOccasion.isOngoing
          ? TimerTickerBuilder(
              timerOccasion.timer,
              builder: (context, left) => Text(left.toHMSorMS()),
            )
          : Text(timerOccasion.timer.pausedAt.toHMSorMS()),
    );
  }
}

class TimerCardWheel extends StatelessWidget {
  final TimerOccasion timerOccasion;

  const TimerCardWheel(this.timerOccasion, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timer = timerOccasion.timer;
    if (timerOccasion.isOngoing && !timer.paused) {
      return TimerTickerBuilder(
        timer,
        builder: (context, left) => TimerWheel.simplified(
          secondsLeft: left.inSeconds,
          lengthInMinutes: timer.duration.inMinutes,
        ),
      );
    }
    return TimerWheel.simplified(
      paused: timerOccasion.timer.paused,
      secondsLeft: timerOccasion.timer.paused
          ? timerOccasion.timer.pausedAt.inSeconds
          : 0,
      lengthInMinutes: timerOccasion.timer.duration.inMinutes,
    );
  }
}

class TimerTickerBuilder extends StatelessWidget {
  final AbiliaTimer timer;
  final Widget Function(BuildContext context, Duration timeLeft) builder;

  const TimerTickerBuilder(
    this.timer, {
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ticker = GetIt.I<Ticker>();
    final initialTime =
        timer.duration - ticker.time.difference(timer.startTime);
    return StreamBuilder<Duration>(
      initialData: initialTime.isNegative ? Duration.zero : initialTime,
      stream: ticker.seconds.map((now) => timer.end.difference(now)),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        return builder(context, data.abs());
      },
    );
  }
}
