import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class FullDayStack extends StatelessWidget {
  const FullDayStack({
    required this.numberOfActivities,
    this.width,
    this.height,
    this.goToActivitiesListOnTap = false,
    this.day,
    Key? key,
  })  : assert(!(goToActivitiesListOnTap && day == null)),
        super(key: key);

  final int numberOfActivities;
  final double? width;
  final double? height;
  final bool goToActivitiesListOnTap;
  final DateTime? day;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AbiliaColors.white,
      borderRadius: BorderRadius.circular(layout.monthCalendar.dayRadius),
      border: border,
    );

    final body = Stack(
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

    return goToActivitiesListOnTap
        ? _wrapWithGestureDetector(context, day, body)
        : body;
  }

  Widget _wrapWithGestureDetector(
      BuildContext context, DateTime? day, Widget body) {
    return GestureDetector(
      onTap: () {
        final authProviders = copiedAuthProviders(context);
        if (day != null) {
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
                  child: AllDayList(
                    day: day,
                  ),
                ),
              ),
              settings: RouteSettings(name: 'AllDayList $day'),
            ),
          );
        }
      },
      child: body,
    );
  }
}
