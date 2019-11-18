import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/repositories.dart';
import 'package:seagull/ui/components.dart';

class CalendarPage extends StatelessWidget {
  final Authenticated authenticatedState;
  CalendarPage({@required this.authenticatedState});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<ActivitiesBloc>(
          builder: (context) => ActivitiesBloc(
              activitiesRepository: ActivityRepository(
                  client: authenticatedState.userRepository.client,
                  baseUrl: authenticatedState.userRepository.baseUrl,
                  authToken: authenticatedState.token,
                  userId: authenticatedState.userId))
            ..add(LoadActivities())),
      BlocProvider<ClockBloc>(
        builder: (context) => ClockBloc(Ticker.minute()),
      ),
      BlocProvider<DayPickerBloc>(
        builder: (context) => DayPickerBloc(
          clockBloc: BlocProvider.of<ClockBloc>(context),
        ),
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
    ], child: Calendar());
  }
}
