import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../fakes/all.dart';
import '../mocks/mock_bloc.dart';
import '../test_helpers/register_fallback_values.dart';

void main() {
  late ActivitiesBloc activitiesBloc;
  late StreamController<ActivitiesChanged> activitiesStreamController;
  late Stream<ActivitiesChanged> activitiesStream;

  late SortableBloc sortableBloc;
  late StreamController<SortableState> sortableStreamController;
  late Stream<SortableState> sortableStream;

  late AuthenticatedDialogCubit authenticatedDialogCubit;
  late StreamController<AuthenticatedDialogState>
      authenticatedDialogStreamController;
  late Stream<AuthenticatedDialogState> authenticatedDialogStream;

  late MemoplannerSettingsBloc memoplannerSettingBloc;
  late StreamController<MemoplannerSettings> settingsStreamController;
  late Stream<MemoplannerSettings> settingsStream;

  late NotificationBloc notificationBloc;

  late TimerCubit timerCubit;
  late StreamController<TimerState> timerStreamController;
  late Stream<TimerState> timerStream;

  setUpAll(registerFallbackValues);
  setUp(() async {
    activitiesBloc = MockActivitiesBloc();
    when(() => activitiesBloc.state).thenReturn(ActivitiesChanged());
    activitiesStreamController = StreamController<ActivitiesChanged>();
    activitiesStream = activitiesStreamController.stream.asBroadcastStream();
    when(() => activitiesBloc.stream)
        .thenAnswer((invocation) => activitiesStream);

    sortableBloc = MockSortableBloc();
    when(() => sortableBloc.state).thenReturn(SortablesNotLoaded());
    sortableStreamController = StreamController<SortableState>();
    sortableStream = sortableStreamController.stream.asBroadcastStream();
    when(() => sortableBloc.stream).thenAnswer((invocation) => sortableStream);
    when(() => sortableBloc.addStarter(any()))
        .thenAnswer((invocation) => Future.value());

    authenticatedDialogCubit = MockAuthenticatedDialogCubit();
    when(() => authenticatedDialogCubit.state)
        .thenReturn(const AuthenticatedDialogState());
    authenticatedDialogStreamController =
        StreamController<AuthenticatedDialogState>();
    authenticatedDialogStream =
        authenticatedDialogStreamController.stream.asBroadcastStream();
    when(() => authenticatedDialogCubit.stream)
        .thenAnswer((invocation) => authenticatedDialogStream);

    memoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => memoplannerSettingBloc.state)
        .thenReturn(const MemoplannerSettingsNotLoaded());
    settingsStreamController = StreamController<MemoplannerSettings>();
    settingsStream = settingsStreamController.stream.asBroadcastStream();
    when(() => memoplannerSettingBloc.stream)
        .thenAnswer((invocation) => settingsStream);

    notificationBloc = MockNotificationBloc();

    timerCubit = MockTimerCubit();
    when(() => timerCubit.state).thenReturn(TimerState());
    timerStreamController = StreamController<TimerState>();
    timerStream = timerStreamController.stream.asBroadcastStream();
    when(() => timerCubit.stream).thenAnswer((invocation) => timerStream);

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..sortableDb = FakeSortableDb()
      ..client = Fakes.client()
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(() {
    GetIt.I.reset();
    activitiesStreamController.close();
    sortableStreamController.close();
    authenticatedDialogStreamController.close();
    settingsStreamController.close();
    timerStreamController.close();
  });

  Widget authListener({
    Authenticated state = const Authenticated(user: Fakes.user),
  }) =>
      MaterialApp(
        home: TopLevelProvider(
          child: AuthenticationBlocProvider(
            child: AuthenticatedBlocsProvider(
              authenticatedState: state,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: activitiesBloc),
                  BlocProvider.value(value: sortableBloc),
                  BlocProvider.value(value: authenticatedDialogCubit),
                  BlocProvider.value(value: timerCubit),
                  BlocProvider.value(value: memoplannerSettingBloc),
                  BlocProvider.value(value: notificationBloc),
                  BlocProvider<SpeechSettingsCubit>(
                    create: (c) => FakeSpeechSettingsCubit(),
                  ),
                ],
                child: AuthenticatedListener(
                  newlyLoggedIn: state.newlyLoggedIn,
                  child: const SizedBox.shrink(),
                ),
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
    await tester.pumpWidget(authListener());
    verifyNever(() => notificationBloc.add(any()));

    // Act
    activitiesStreamController.add(
      ActivitiesChanged(),
    );
    await tester.pumpAndSettle();

    // Assert
    verify(() => notificationBloc.add(any()));
  });

  testWidgets('when settings we schedule alarms', (tester) async {
    // Arrange
    when(() => activitiesBloc.state).thenReturn(
      ActivitiesChanged(),
    );
    await tester.pumpWidget(authListener());
    expect(scheduleNotificationsCalls, 0);
    // Act
    settingsStreamController
        .add(MemoplannerSettingsLoaded(const MemoplannerSettings()));
    await tester.pumpAndSettle();

    // Assert
    verify(() => notificationBloc.add(any()));
  });

  testWidgets('when timers update, we schedule alarms', (tester) async {
    // Arrange
    when(() => activitiesBloc.state).thenReturn(ActivitiesChanged());
    when(() => memoplannerSettingBloc.state)
        .thenReturn(const MemoplannerSettingsFailed());
    await tester.pumpWidget(authListener());

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
    verify(() => notificationBloc.add(any()));
  });

  testWidgets('Shows starter set dialog and call add when pressed Yes',
      (tester) async {
    // Arrange
    when(() => authenticatedDialogCubit.state)
        .thenAnswer((_) => const AuthenticatedDialogState());

    // Act - Start app
    await tester.pumpWidget(authListener(
        state: const Authenticated(user: Fakes.user, newlyLoggedIn: true)));
    await tester.pumpAndSettle();

    // Assert - No dialog
    expect(find.byType(AuthenticatedDialog), findsNothing);
    expect(find.byType(StarterSetDialog), findsNothing);

    // Act - Login dialog is ready
    const starterSetState = AuthenticatedDialogState(
      termsOfUseLoaded: true,
      starterSet: true,
      starterSetLoaded: true,
      fullscreenAlarmLoaded: true,
    );
    authenticatedDialogStreamController.add(starterSetState);
    when(() => authenticatedDialogCubit.state)
        .thenAnswer((_) => starterSetState);
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(AuthenticatedDialog), findsOneWidget);
    expect(find.byType(StarterSetDialog), findsOneWidget);

    // Act - Press Yes
    await tester.tap(find.byType(YesButton));
    await tester.pumpAndSettle();

    // Assert - addStarter is called
    verify(() => sortableBloc.addStarter(any())).called(1);
  });
}
