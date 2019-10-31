import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/repositories.dart';
import 'package:seagull/ui/components.dart';

class CalenderPage extends StatelessWidget {
  final Authenticated authenticatedState;
  CalenderPage({@required this.authenticatedState});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<ActivitiesBloc>(
          builder: (context) => ActivitiesBloc(
              activitiesRepository: ActivityRepository(
                  authToken: authenticatedState.token,
                  userId: authenticatedState.userId))
            ..add(LoadActivities())),
      BlocProvider<DayPickerBloc>(
        builder: (context) => DayPickerBloc(),
      ),
      BlocProvider<ClockBloc>(
        builder: (context) => ClockBloc(Ticker.minute()),
      ),
      BlocProvider<FilteredActivitiesBloc>(
        builder: (context) => FilteredActivitiesBloc(
            activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
            dayPickerBloc: BlocProvider.of<DayPickerBloc>(context)),
      )
    ], child: Calender());
  }
}
