import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class TimerCard extends StatelessWidget {
  final TimerOccasion timerOccasion;
  final DateTime day;
  final bool useOpacity;

  const TimerCard({
    required this.timerOccasion,
    required this.day,
    this.useOpacity = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPast = timerOccasion.isPast;
    final themeData = abiliaTheme.copyWith(
      iconTheme: abiliaTheme.iconTheme.copyWith(
        color: isPast ? AbiliaColors.white140 : null,
      ),
    );
    return AnimatedTheme(
      duration: ActivityCard.duration,
      data: themeData,
      child: Builder(
        builder: (context) {
          return Tts.fromSemantics(
            timerOccasion.timer.semanticsProperties(context),
            child: Opacity(
              opacity: useOpacity ? (isPast ? 0.3 : 0.4) : 1,
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
                          settings: (TimerPage).routeSetting(),
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
                                radius: layout.eventCard.imageRadius,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: layout.eventCard.titlePadding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (timerOccasion.timer.hasTitle) ...[
                                  Text(
                                    timerOccasion.timer.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(height: 1),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  SizedBox(
                                    height:
                                        layout.eventCard.titleSubtitleSpacing,
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}

class TimeLeft extends StatelessWidget {
  final TimerOccasion timerOccasion;
  final TextStyle? textStyle;

  const TimeLeft(
    this.timerOccasion, {
    this.textStyle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyText4 = layout.eventCard.bodyText4.copyWith(
      color: timerOccasion.isPast ? AbiliaColors.white140 : null,
      height: 1,
    );

    return DefaultTextStyle(
      style: textStyle ?? bodyText4,
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
