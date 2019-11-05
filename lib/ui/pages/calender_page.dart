import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/main.dart';
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
                client: (context.ancestorWidgetOfExactType(App) as App).httpClient,
                  authToken: authenticatedState.token,
                  userId: authenticatedState.userId))
            ..add(LoadActivities())),
      BlocProvider<DayPickerBloc>(
        builder: (context) => DayPickerBloc(),
      ),
      BlocProvider<ClockBloc>(
        builder: (context) => ClockBloc(Ticker.minute()),
      ),
      BlocProvider<DayActivitiesBloc>(
        builder: (context) => DayActivitiesBloc(
          activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
          dayPickerBloc: BlocProvider.of<DayPickerBloc>(context),
        ),
      ),
      BlocProvider<ActivitiesOccasionBloc>(
        builder: (context) => ActivitiesOccasionBloc(
          clockBloc: BlocProvider.of<ClockBloc>(context),
          dayActivitiesBloc: BlocProvider.of<DayActivitiesBloc>(context),
        ),
      ),
    ], child: Calender());
  }
}
