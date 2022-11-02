import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class FullDayStack extends StatelessWidget {
  const FullDayStack({
    required this.numberOfActivities,
    this.width,
    this.height,
    Key? key,
  }) : super(key: key);

  final double? width;
  final double? height;

  final int numberOfActivities;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AbiliaColors.white,
      borderRadius: BorderRadius.circular(layout.monthCalendar.dayRadius),
      border: border,
    );
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
              top: layout.commonCalendar.fullDayStackDistance,
              left: layout.commonCalendar.fullDayStackDistance),
          width: width,
          height: height,
          decoration: decoration,
        ),
        Container(
          margin: EdgeInsets.only(
              bottom: layout.commonCalendar.fullDayStackDistance,
              right: layout.commonCalendar.fullDayStackDistance),
          decoration: decoration,
          width: width,
          height: height,
          child: Center(
            child: Text('+$numberOfActivities'),
          ),
        ),
      ],
    );
  }
}

class ClickableFullDayStack extends StatelessWidget {
  const ClickableFullDayStack({
    required this.fullDayActivitiesBuilder,
    required this.numberOfActivities,
    required this.day,
    this.width,
    this.height,
    Key? key,
  }) : super(key: key);

  final List<ActivityOccasion> Function(BuildContext context)
      fullDayActivitiesBuilder;
  final int numberOfActivities;
  final DateTime day;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final authProviders = copiedAuthProviders(context);
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, animation, secondaryAnimation) =>
                MultiBlocProvider(
              providers: authProviders,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: Builder(builder: (context) {
                  return FullDayListPage(
                    day: day,
                    fullDayActivities: fullDayActivitiesBuilder(context),
                  );
                }),
              ),
            ),
            settings: RouteSettings(name: 'FullDayListPage $day'),
          ),
        );
      },
      child: FullDayStack(
        width: width,
        height: height,
        numberOfActivities: numberOfActivities,
      ),
    );
  }
}
