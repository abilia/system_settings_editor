import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class TimerTimepillardCard extends TimerpillarCard {
  final TimepillarState ts;
  final TimerOccasion timerOccasion;
  const TimerTimepillardCard({
    required this.ts,
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
    );
    final padding = ts.cardPadding
        .subtract(decoration.border?.dimensions ?? EdgeInsets.zero)
        .clamp(EdgeInsets.zero, ts.cardPadding);
    return Positioned(
      left: column * ts.cardTotalWidth,
      top: cardPosition.top,
      child: Tts.fromSemantics(
        timer.semanticsProperties(context),
        child: GestureDetector(
          onTap: () {
            final authProviders = copiedAuthProviders(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: authProviders,
                  child: TimerPage(
                    timer: timerOccasion.timer,
                    day: context.read<DayPickerBloc>().state.day,
                  ),
                ),
              ),
            );
          },
          child: Container(
            decoration: decoration,
            height: cardPosition.height,
            width: ts.cardWidth,
            padding: padding,
            margin: EdgeInsets.only(left: ts.dotSize + ts.hourPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: ts.timerWheelPadding,
                  child: SizedBox.fromSize(
                    size: ts.timerWheelSize,
                    child: TimerCardWheel(timerOccasion),
                  ),
                ),
                if (timer.hasImage)
                  SizedBox(
                    height: ts.cardMinImageHeight,
                    child: EventImage.fromEventOccasion(
                      eventOccasion: timerOccasion,
                      crossPadding: ts.cardPadding,
                      checkPadding: ts.cardPadding * 2,
                    ),
                  )
                else if (timer.hasTitle)
                  Text(timer.title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
