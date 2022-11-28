import 'package:flutter/widgets.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';

import 'fake_db_and_repository.dart';
import 'fakes_blocs.dart';

class FakeAuthenticatedBlocsProvider extends StatelessWidget {
  final Widget child;

  const FakeAuthenticatedBlocsProvider({
    required this.child,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => FakeUserRepository(),
        ),
        RepositoryProvider<ActivityRepository>(
          create: (context) => FakeActivityRepository(),
        ),
      ],
      child: MultiBlocProvider(providers: [
        BlocProvider<AuthenticationBloc>(
            create: (context) => FakeAuthenticationBloc()),
        BlocProvider<ActivitiesBloc>(create: (context) => FakeActivitiesBloc()),
        BlocProvider<SpeechSettingsCubit>(
            create: (context) => FakeSpeechSettingsCubit()),
        BlocProvider<PermissionCubit>(create: (context) => PermissionCubit()),
        BlocProvider<SyncBloc>(create: (context) => FakeSyncBloc()),
        BlocProvider<UserFileCubit>(create: (context) => FakeUserFileCubit()),
        BlocProvider<SortableBloc>(create: (context) => FakeSortableBloc()),
        BlocProvider<GenericCubit>(create: (context) => FakeGenericCubit()),
        BlocProvider<MemoplannerSettingsBloc>(
            create: (context) => FakeMemoplannerSettingsBloc()),
        BlocProvider<DayPickerBloc>(create: (context) => FakeDayPickerBloc()),
        BlocProvider<DayEventsCubit>(create: (context) => FakeDayEventsCubit()),
        BlocProvider<AlarmCubit>(create: (context) => FakeAlarmCubit()),
        BlocProvider<CalendarViewCubit>(
            create: (context) => FakeCalendarViewBloc()),
        BlocProvider<LicenseCubit>(create: (context) => FakeLicenseCubit()),
      ], child: child),
    );
  }
}