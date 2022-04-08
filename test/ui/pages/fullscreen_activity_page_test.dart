import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/ticker.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/alarm_navigator.dart';
import 'package:seagull/utils/datetime.dart';
import 'package:seagull/utils/duration.dart';

import '../../fakes/all.dart';
import '../../mocks/mock_bloc.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  late StreamController<DateTime> mockTicker;
  late MockActivityDb mockActivityDb;
  late MockGenericDb mockGenericDb;
  late MockMemoplannerSettingBloc mockMemoplannerSettingBloc;
  late MockActivitiesBloc mockActivitiesBloc;
  final startTimeOne = DateTime(2122, 06, 06, 06, 00);
  final startTimeTwo = DateTime(2122, 06, 06, 06, 02);
  final initialMinutes = DateTime(2122, 06, 06, 06, 10);

  final fullScreenActivityPageFinder = find.byType(FullScreenActivityPage);

  final AlarmNavigator _alarmNavigator = AlarmNavigator();
  late ClockBloc clockBloc;

  final List<Activity> fakeActivities = [
    FakeActivity.starts(startTimeOne,
        duration: const Duration(minutes: 5), title: 'Test1'),
    FakeActivity.starts(startTimeTwo,
        duration: const Duration(minutes: 1), title: 'Test2')
  ];
  final List<ActivityDay> dayActivities = [
    ActivityDay(fakeActivities[0], fakeActivities[0].startTime.onlyDays()),
    ActivityDay(fakeActivities[1], fakeActivities[1].startTime.onlyDays())
  ];
  final testActivity = Activity.createNew(
    title: 'title',
    startTime: startTimeOne,
  );

  final StartAlarm startAlarm =
      StartAlarm(ActivityDay(testActivity, startTimeOne.onlyDays()));

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    await initializeDateFormatting();
    mockMemoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(MemoplannerSettings(
            alarm: AlarmSettings(showOngoingActivityInFullScreen: true))));
    mockActivityDb = MockActivityDb();
    when(() => mockActivityDb.getAllDirty())
        .thenAnswer((_) => Future.value(<DbActivity>[]));
    when(() => mockActivityDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));
    when(() => mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(fakeActivities));
    mockGenericDb = MockGenericDb();
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value([]));

    mockActivitiesBloc = MockActivitiesBloc();
    clockBloc = ClockBloc.fixed(initialMinutes);
    mockTicker = StreamController<DateTime>();

    final expected = ActivitiesLoaded(fakeActivities);

    when(() => mockActivitiesBloc.state).thenReturn(expected);
    when(() => mockActivitiesBloc.stream)
        .thenAnswer((_) => Stream.fromIterable([expected]));
    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker.fake(
        stream: mockTicker.stream,
        initialTime: initialMinutes,
      )
      ..genericDb = mockGenericDb
      ..database = FakeDatabase()
      ..fireBasePushService = FakeFirebasePushService()
      ..client = Fakes.client(
        activityResponse: () => [],
        licenseResponse: () =>
            Fakes.licenseResponseExpires(startTimeOne.add(5.days())),
      )
      ..fileStorage = FakeFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..sortableDb = FakeSortableDb()
      ..init();
  });

  tearDown(() {
    mockTicker.close();
    GetIt.I.reset();
  });

  Widget wrapWithMaterialApp(Widget widget) => FakeAuthenticatedBlocsProvider(
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ActivitiesBloc>(
              create: (context) => mockActivitiesBloc,
            ),
            BlocProvider<ClockBloc>(
              create: (context) => clockBloc,
            ),
            BlocProvider<SettingsCubit>(
              create: (context) => SettingsCubit(
                settingsDb: FakeSettingsDb(),
              ),
            ),
            BlocProvider<MemoplannerSettingBloc>(
              create: (context) => mockMemoplannerSettingBloc,
            ),
            BlocProvider<AlarmCubit>(
              create: (context) => AlarmCubit(
                selectedNotificationSubject: ReplaySubject<ActivityAlarm>(),
                activitiesBloc: mockActivitiesBloc,
                clockBloc: clockBloc,
              ),
            ),
            BlocProvider<TimepillarCubit>(
                create: (context) => FaketimepillarCubit()),
          ],
          child: MaterialApp(
            supportedLocales: Translator.supportedLocals,
            localizationsDelegates: const [Translator.delegate],
            localeResolutionCallback: (locale, supportedLocales) =>
                supportedLocales.firstWhere(
                    (l) => l.languageCode == locale?.languageCode,
                    orElse: () => supportedLocales.first),
            home: Material(child: widget),
          ),
        ),
      );

  group('FullscreenActivityPage', () {
    group('Static timer', () {
      testWidgets('Fullpage activity shows, two activities in bottom bar',
          (WidgetTester tester) async {
        clockBloc.emit(fakeActivities[1].startTime);
        await tester.pumpWidget(
          wrapWithMaterialApp(
            PopAwareAlarmPage(
              alarm: startAlarm,
              alarmNavigator: _alarmNavigator,
              child: FullScreenActivityPage(activityDay: dayActivities.first),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(fullScreenActivityPageFinder, findsOneWidget);
        expect(find.byType(FullScreenActivityTabItem), findsNWidgets(2));
      });

      testWidgets('Show activity two', (WidgetTester tester) async {
        clockBloc.emit(fakeActivities[0].startTime);
        await tester.pumpWidget(
          wrapWithMaterialApp(
            PopAwareAlarmPage(
              alarm: startAlarm,
              alarmNavigator: _alarmNavigator,
              child: FullScreenActivityPage(activityDay: dayActivities[0]),
            ),
          ),
        );
        await tester.pumpAndSettle();
        clockBloc.emit(fakeActivities[1].startTime);
        await tester.pumpAndSettle();
        expect(fullScreenActivityPageFinder, findsOneWidget);
        expect(find.text(fakeActivities[1].title), findsNWidgets(2));
        expect(find.byType(FullScreenActivityTabItem), findsNWidgets(2));
      });

      testWidgets('Tapping activity in bottom bar selects it',
          (WidgetTester tester) async {
        clockBloc.emit(fakeActivities[1].startTime);
        await tester.pumpWidget(
          wrapWithMaterialApp(
            PopAwareAlarmPage(
              alarm: startAlarm,
              alarmNavigator: _alarmNavigator,
              child: FullScreenActivityPage(activityDay: dayActivities[1]),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(fakeActivities[1].title), findsNWidgets(2));
        await tester.tap(find.byType(FullScreenActivityTabItem).first);
        await tester.pumpAndSettle();
        expect(find.text(fakeActivities[0].title), findsNWidgets(2));
      });
    });
  });
}
