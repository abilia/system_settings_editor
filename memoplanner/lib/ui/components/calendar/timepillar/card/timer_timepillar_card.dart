import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class TimerTimepillardCard extends TimepillarCard {
  final TimerOccasion timerOccasion;
  final TimepillarMeasures measures;
  const TimerTimepillardCard({
    required this.measures,
    required int column,
    required this.timerOccasion,
    required CardPosition cardPosition,
    Key? key,
  }) : super(column, cardPosition, key: key);

  @override
  Widget build(BuildContext context) {
    final timer = timerOccasion.timer;
    final decoration = getCategoryBoxDecoration(
      current: timerOccasion.isOngoing,
      inactive: timerOccasion.isPast,
      showCategoryColor: false,
      category: timerOccasion.category,
      zoom: measures.zoom,
    );
    final padding = measures.cardPadding
        .subtract(decoration.border?.dimensions ?? EdgeInsets.zero);
    return Positioned(
      left: column * measures.cardTotalWidth,
      top: cardPosition.top,
      child: Tts.fromSemantics(
        timer.semanticsProperties(context),
        child: GestureDetector(
          onTap: () {
            final authProviders = copiedAuthProviders(context);
            final day = context.read<DayPickerBloc>().state.day;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
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
          child: Container(
            decoration: decoration,
            height: cardPosition.height,
            width: measures.cardWidth,
            padding: padding,
            margin: EdgeInsets.only(
                left: measures.dotSize + measures.hourIntervalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: measures.timerWheelPadding,
                  child: SizedBox.fromSize(
                    size: measures.timerWheelSize,
                    child: TimerCardWheel(timerOccasion),
                  ),
                ),
                if (timer.hasImage)
                  SizedBox(
                    height: measures.cardMinImageHeight,
                    child: EventImage.fromEventOccasion(
                      eventOccasion: timerOccasion,
                      crossPadding: measures.cardPadding,
                      checkPadding: measures.cardPadding * 2,
                    ),
                  )
                else if (timer.hasTitle)
                  Text(timer.title)
                else if (!timer.hasTitle && !timer.hasImage)
                  timerOccasion.isOngoing
                      ? TimerTickerBuilder(
                          timerOccasion.timer,
                          builder: (context, left) => Text(left.toHMSorMS()),
                        )
                      : Text(timerOccasion.timer.pausedAt.toHMSorMS()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
