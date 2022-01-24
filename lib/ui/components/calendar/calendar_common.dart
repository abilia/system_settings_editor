import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class FullDayStack extends StatelessWidget {
  const FullDayStack({
    Key? key,
    required this.numberOfActivities,
    this.width,
    this.height,
    this.goToActivitiesListOnTap = false,
    this.day,
  })  : assert(!(goToActivitiesListOnTap && day == null),
            'When goToActivitiesListOnTap is true, day must not be null'),
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
          margin: EdgeInsets.only(top: 4.s, left: 4.s),
          width: width,
          height: height,
          decoration: decoration,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 4.s, right: 4.s),
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
        ? GestureDetector(
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
                      child: const AllDayList(),
                    ),
                  ),
                  settings: RouteSettings(name: 'AllDayList $day'),
                ),
              );
            },
            child: body,
          )
        : body;
  }
}
