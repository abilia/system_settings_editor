import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/alarm_navigator.dart';
import 'package:seagull_fakes/all.dart';

import '../fakes/all.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final time = DateTime(2022, 01, 01);
  final activityDay = ActivityDay(Activity.createNew(startTime: time), time);
  final getItInitializer = GetItInitializer();

  final FullScreenActivityCubit fullScreenActivityCubit =
      FullScreenActivityCubit(
    activitiesBloc: FakeActivitiesBloc(),
    activityRepository: FakeActivityRepository(),
    clockBloc: ClockBloc.fixed(time),
    alarmCubit: FakeAlarmCubit(),
    startingActivity: activityDay,
  );

  setUp(() async {
    getItInitializer
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..alarmNavigator = AlarmNavigator()
      ..init();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Widget wrapWithMaterialApp() {
    final navKey = GlobalKey<NavigatorState>();
    return MaterialApp(
      navigatorKey: navKey,
      builder: (context, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final route = MaterialPageRoute(
            builder: (context) => const Text('Fullscreen activity'),
          );
          GetIt.I<AlarmNavigator>().addRouteOnStack(route);
          navKey.currentState?.push(route);
        });
        return BlocProvider<FullScreenActivityCubit>(
          create: (context) => fullScreenActivityCubit,
          child: FullscreenActivityListener(
            child: child!,
          ),
        );
      },
      home: Container(color: Colors.blueGrey),
    );
  }

  final nullEventListState = FullScreenActivityState(
    selected: fullScreenActivityCubit.state.selected,
    eventsList: null,
  );

  final emptyEventListState = FullScreenActivityState(
    selected: fullScreenActivityCubit.state.selected,
    eventsList: UnmodifiableListView([]),
  );

  final filledEventListState = FullScreenActivityState(
    selected: fullScreenActivityCubit.state.selected,
    eventsList: UnmodifiableListView([
      ActivityOccasion(
        activityDay.activity,
        activityDay.day,
        Occasion.current,
      )
    ]),
  );

  testWidgets('Pop when event list is empty', (tester) async {
    // Arrange
    fullScreenActivityCubit.emit(nullEventListState);
    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();

    // Expect - Pushed widget is shown
    expect(find.byType(Text), findsOneWidget);
    expect(find.byType(Container), findsNothing);

    // Act - Emit an empty event list
    fullScreenActivityCubit.emit(filledEventListState);
    await tester.pumpAndSettle();

    // Expect - Pushed widget is still shown
    expect(find.byType(Text), findsOneWidget);
    expect(find.byType(Container), findsNothing);

    // Act - Emit an empty event list
    fullScreenActivityCubit.emit(emptyEventListState);
    await tester.pumpAndSettle();

    // Act - Pushed widget is popped and parent widget is shown
    expect(find.byType(Text), findsNothing);
    expect(find.byType(Container), findsOneWidget);
  });
}
