import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/all.dart';

import 'fakes_blocs.dart';

class FakeAuthenticatedBlocsProvider extends StatelessWidget {
  final Widget child;

  const FakeAuthenticatedBlocsProvider({Key? key, required this.child})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<AuthenticationBloc>(
          create: (context) => FakeAuthenticationBloc()),
      BlocProvider<ActivitiesBloc>(create: (context) => FakeActivitiesBloc()),
      BlocProvider<SettingsBloc>(create: (context) => FakeSettingsBloc()),
      BlocProvider<PermissionBloc>(create: (context) => PermissionBloc()),
      BlocProvider<SyncBloc>(create: (context) => FakeSyncBloc()),
      BlocProvider<UserFileBloc>(create: (context) => FakeUserFileBloc()),
      BlocProvider<SortableBloc>(create: (context) => FakeSortableBloc()),
      BlocProvider<GenericBloc>(create: (context) => FakeGenericBloc()),
      BlocProvider<MemoplannerSettingBloc>(
          create: (context) => FakeMemoplannerSettingsBloc()),
      BlocProvider<DayPickerBloc>(create: (context) => FakeDayPickerBloc()),
      BlocProvider<DayActivitiesBloc>(
          create: (context) => FakeDayActivitiesBloc()),
      BlocProvider<ActivitiesOccasionBloc>(
          create: (context) => FakeActivitiesOccasionBloc()),
      BlocProvider<AlarmCubit>(create: (context) => FakeAlarmCubit()),
      BlocProvider<NotificationCubit>(
          create: (context) => FakeNotificationBloc()),
      BlocProvider<CalendarViewCubit>(
          create: (context) => FakeCalendarViewBloc()),
      BlocProvider<LicenseBloc>(create: (context) => FakeLicenseBloc()),
    ], child: child);
  }
}