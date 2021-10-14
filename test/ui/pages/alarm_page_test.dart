import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/activities/activities_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/clock/clock_bloc.dart';
import 'package:seagull/bloc/settings/settings_bloc.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/alarm_navigator.dart';
import 'package:seagull/utils/datetime.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../fakes/all.dart';

void main() {
  final startTime = DateTime(2011, 11, 11, 11, 11);
  final day = startTime.onlyDays();
  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<ActivitiesBloc>(
            create: (context) => FakeActivitiesBloc(),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc(StreamController<DateTime>().stream,
                initialTime: day),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              settingsDb: FakeSettingsDb(),
            ),
          ),
          BlocProvider<UserFileBloc>(
            create: (context) => UserFileBloc(
              fileStorage: FakeFileStorage(),
              pushBloc: FakePushBloc(),
              syncBloc: FakeSyncBloc(),
              userFileRepository: FakeUserFileRepository(),
            ),
          ),
        ], child: widget),
      );

  setUp(() async {
    await initializeDateFormatting();
    GetItInitializer()
      ..fileStorage = FakeFileStorage()
      ..database = FakeDatabase()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('alarm speech tests', () {
    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime,
      checkable: true,
      reminderBefore: [],
      signedOffDates: [day],
      extras: Extras.createNew(
          startTimeExtraAlarm:
              UnstoredAbiliaFile.forTest('id', 'path', File('test.mp3'))),
    );

    final StartAlarm startAlarm = StartAlarm(activity, day);
    final EndAlarm endAlarm = EndAlarm(activity, day);
    AlarmNavigator _alarmNavigator = AlarmNavigator();

    testWidgets('Alarm page visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(PopAwareAlarmPage(
          alarm: startAlarm,
          alarmNavigator: _alarmNavigator,
          child: AlarmPage(alarm: startAlarm),
        )),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlarmPage), findsOneWidget);
    });

    testWidgets('Start alarm shows play speech button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(PopAwareAlarmPage(
          alarm: startAlarm,
          alarmNavigator: _alarmNavigator,
          child: AlarmPage(alarm: startAlarm),
        )),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PlaySpeechButton), findsOneWidget);
    });

    testWidgets('End alarm does not show play speech button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(PopAwareAlarmPage(
          alarm: startAlarm,
          alarmNavigator: _alarmNavigator,
          child: AlarmPage(alarm: endAlarm),
        )),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PlaySpeechButton), findsNothing);
    });
  });
}
