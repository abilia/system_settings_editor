import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class TimerTimepillardCard extends TimepillarCard {
  final TimerOccasion timerOccasion;
  final TimepillarMeasures measures;
  final BoxDecoration decoration;

  const TimerTimepillardCard({
    required this.measures,
    required int column,
    required this.timerOccasion,
    required CardPosition cardPosition,
    required this.decoration,
    Key? key,
  }) : super(column, cardPosition, key: key);

  @override
  Widget build(BuildContext context) {
    final timer = timerOccasion.timer;
    final borderWidth = (decoration.padding?.vertical ?? 0) / 2;
    final imagePadding = measures.imagePadding.vertical / 2;
    final textPadding = measures.textPadding.vertical / 2;
    final timerWheelPadding = measures.timerWheelPadding.vertical / 2;
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
            margin: EdgeInsets.only(
                left: measures.dotSize + measures.hourIntervalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: timerWheelPadding - borderWidth),
                SizedBox.fromSize(
                  size: measures.timerWheelSize,
                  child: TimerCardWheel(timerOccasion),
                ),
                if (timer.hasImage) ...[
                  SizedBox(height: imagePadding),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        height: measures.cardImageSize,
                        width: measures.cardImageSize,
                        child: EventImage.fromEventOccasion(
                          eventOccasion: timerOccasion,
                          crossPadding: measures.crossPadding,
                          checkPadding: measures.checkPadding,
                          radius: layout.timepillar.card.imageCornerRadius,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: imagePadding - borderWidth),
                ] else if (timer.hasTitle) ...[
                  SizedBox(height: textPadding),
                  SizedBox(
                    width: measures.cardTextWidth,
                    child: Text(
                      timer.title,
                      maxLines: TimepillarCard.defaultTitleLines,
                    ),
                  ),
                  SizedBox(height: textPadding - borderWidth),
                ] else if (!timer.hasTitle && !timer.hasImage) ...[
                  SizedBox(height: textPadding),
                  if (timerOccasion.isOngoing)
                    TimerTickerBuilder(
                      timerOccasion.timer,
                      builder: (context, left) => Text(left.toHMSorMS()),
                    )
                  else
                    Text(timerOccasion.timer.pausedAt.toHMSorMS()),
                  SizedBox(height: textPadding - borderWidth),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
