import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class TimerCard extends StatelessWidget {
  final TimerOccasion timerOccasion;
  const TimerCard({
    Key? key,
    required this.timerOccasion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO Use a second garanularity timer
    final isPast = timerOccasion.occasion == Occasion.past;
    final isCurrent = timerOccasion.occasion == Occasion.current;
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
        builder: (context) => Container(
          height: layout.activityCard.height,
          decoration: getCategoryBoxDecoration(
            current: isCurrent,
            inactive: isPast,
            category: timerOccasion.event.category,
            showCategoryColor: true,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: borderRadius - BorderRadius.circular(1.0),
              onTap: () {},
              child: Padding(
                padding: layout.activityCard.titlePadding,
                child: Text(
                  timerOccasion.event.title,
                  style: Theme.of(context).textTheme.subtitle1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
