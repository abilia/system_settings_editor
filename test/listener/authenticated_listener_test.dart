import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import '../fakes/all.dart';
import '../mocks/mock_bloc.dart';
import '../test_helpers/register_fallback_values.dart';

void main() {
  late ActivitiesBloc activitiesBloc;
  late StreamController<ActivitiesState> activitiesStreamController;
  late Stream<ActivitiesState> activitiesStream;

  late MemoplannerSettingBloc memoplannerSettingBloc;
  late StreamController<MemoplannerSettingsState> settingsStreamController;
  late Stream<MemoplannerSettingsState> settingsStream;

  late TimerCubit timerCubit;
  late StreamController<TimerState> timerStreamController;
  late Stream<TimerState> timerStream;

  setUpAll(registerFallbackValues);
  setUp(() async {
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    activitiesBloc = MockActivitiesBloc();
    when(() => activitiesBloc.state).thenReturn(ActivitiesNotLoaded());
    activitiesStreamController = StreamController<ActivitiesState>();
    activitiesStream = activitiesStreamController.stream.asBroadcastStream();
    when(() => activitiesBloc.stream)
        .thenAnswer((invocation) => activitiesStream);

    memoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => memoplannerSettingBloc.state)
        .thenReturn(const MemoplannerSettingsNotLoaded());
    settingsStreamController = StreamController<MemoplannerSettingsState>();
    settingsStream = settingsStreamController.stream.asBroadcastStream();
    when(() => memoplannerSettingBloc.stream)
        .thenAnswer((invocation) => settingsStream);

    timerCubit = MockTimerCubit();
    when(() => timerCubit.state).thenReturn(TimerState());
    timerStreamController = StreamController<TimerState>();
    timerStream = timerStreamController.stream.asBroadcastStream();
    when(() => timerCubit.stream).thenAnswer((invocation) => timerStream);

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..client = Fakes.client()
      ..battery = FakeBattery()
      ..init();
  });

  tearDown(() {
    GetIt.I.reset();
    activitiesStreamController.close();
    settingsStreamController.close();
    timerStreamController.close();
  });

  Widget _authListener() => MaterialApp(
        home: TopLevelBlocsProvider(
          runStartGuide: false,
          child: AuthenticatedBlocsProvider(
            authenticatedState: const Authenticated(
              userId: 5,
            ),
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: activitiesBloc),
                BlocProvider.value(value: timerCubit),
                BlocProvider.value(value: memoplannerSettingBloc),
              ],
              child: const AuthenticatedListener(
                child: SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

  final now = DateTime(2022, 02, 25, 12, 12);
  testWidgets('when activites update, we schedule alarms', (tester) async {
    // Arrange
    when(() => memoplannerSettingBloc.state)
        .thenReturn(const MemoplannerSettingsFailed());
    await tester.pumpWidget(_authListener());
    expect(alarmScheduleCalls, 0);

    // Act
    activitiesStreamController.add(
      ActivitiesLoaded(
        [Activity.createNew(startTime: now)],
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(alarmScheduleCalls, 1);
  });

  testWidgets('when settings we schedule alarms', (tester) async {
    // Arrange
    when(() => activitiesBloc.state).thenReturn(
      ActivitiesLoaded([Activity.createNew(startTime: now)]),
    );
    await tester.pumpWidget(_authListener());
    expect(alarmScheduleCalls, 0);
    // Act
    settingsStreamController
        .add(const MemoplannerSettingsLoaded(MemoplannerSettings()));
    await tester.pumpAndSettle();

    // Assert
    expect(alarmScheduleCalls, 1);
  });

  testWidgets('when timers update, we schedule alarms', (tester) async {
    // Arrange
    when(() => activitiesBloc.state).thenReturn(ActivitiesLoaded(
      [Activity.createNew(startTime: now)],
    ));
    when(() => memoplannerSettingBloc.state)
        .thenReturn(const MemoplannerSettingsFailed());
    await tester.pumpWidget(_authListener());

    // Act
    timerStreamController.add(
      TimerState(
        timers: [
          AbiliaTimer.createNew(
              startTime: now, duration: const Duration(minutes: 1))
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(alarmScheduleCalls, 1);
  });
}
