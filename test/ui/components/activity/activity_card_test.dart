import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uuid/uuid.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';

import '../../../mocks_and_fakes/fake_db_and_repository.dart';
import '../../../mocks_and_fakes/fakes_blocs.dart';
import '../../../mocks_and_fakes/fake_shared_preferences.dart';
import '../../../test_helpers/tts.dart';

void main() {
  final startTime = DateTime(2011, 11, 11, 11, 11);

  Future pumpActivityCard(
    WidgetTester tester,
    Activity activity, [
    Occasion? occasion,
  ]) =>
      tester
          .pumpWidget(
            MaterialApp(
              supportedLocales: Translator.supportedLocals,
              localizationsDelegates: [Translator.delegate],
              localeResolutionCallback: (locale, supportedLocales) =>
                  supportedLocales.firstWhere(
                      (l) => l.languageCode == locale?.languageCode,
                      orElse: () => supportedLocales.first),
              home: MultiBlocProvider(
                providers: [
                  BlocProvider<AuthenticationBloc>(
                      create: (context) => FakeAuthenticationBloc()),
                  BlocProvider<UserFileBloc>(
                    create: (context) => UserFileBloc(
                      fileStorage: FakeFileStorage(),
                      pushBloc: FakePushBloc(),
                      syncBloc: FakeSyncBloc(),
                      userFileRepository: FakeUserFileRepository(),
                    ),
                  ),
                  BlocProvider<ClockBloc>(
                    create: (context) => ClockBloc(
                        StreamController<DateTime>().stream,
                        initialTime: startTime),
                  ),
                  BlocProvider<SettingsBloc>(
                    create: (context) => SettingsBloc(
                      settingsDb: FakeSettingsDb(),
                    ),
                  ),
                ],
                child: Material(
                  child: ActivityCard(
                    activityOccasion: ActivityOccasion.forTest(activity,
                        occasion: occasion ?? Occasion.current),
                  ),
                ),
              ),
            ),
          )
          .then((_) => tester.pumpAndSettle());

  setUp(() async {
    setupFakeTts();
    await initializeDateFormatting();
    GetItInitializer()
      ..fileStorage = FakeFileStorage()
      ..database = FakeDatabase()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('has title ', (WidgetTester tester) async {
    final title = 'title';
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: title,
        startTime: startTime,
      ),
    );

    // Asert title but no image
    expect(find.byType(ActivityCard), findsOneWidget);
    expect(find.text(title), findsOneWidget);
    expect(find.byType(ActivityImage), findsNothing);
  });

  testWidgets('has image ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: '',
        fileId: 'fileid',
        startTime: startTime,
      ),
    );
    tester.takeException();

    // Assert image
    expect(find.byType(ActivityCard), findsOneWidget);
    expect(find.byType(ActivityImage), findsOneWidget);
  });

  testWidgets('has title and image ', (WidgetTester tester) async {
    final title = 'title';
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: title,
        fileId: 'fileid',
        startTime: startTime,
      ),
    );
    tester.takeException();

    // Assert title and image
    expect(find.byType(ActivityCard), findsOneWidget);
    expect(find.text(title), findsOneWidget);
    expect(find.byType(ActivityImage), findsOneWidget);
  });

  testWidgets('icon for checkable activity', (WidgetTester tester) async {
    await pumpActivityCard(
        tester,
        Activity.createNew(
            title: 'title', startTime: startTime, checkable: true));

    // Assert title no image
    expect(find.byIcon(AbiliaIcons.handi_check), findsOneWidget);
  });
  testWidgets('icon for alarm and vibration ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        alarmType: ALARM_SOUND_AND_VIBRATION,
      ),
    );
    expect(find.byIcon(AbiliaIcons.handi_alarm_vibration), findsOneWidget);
  });

  testWidgets('icon for vibration ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        alarmType: ALARM_VIBRATION,
      ),
    );
    expect(find.byIcon(AbiliaIcons.handi_vibration), findsOneWidget);
  });

  testWidgets('icon for no alarm nor vibration ', (WidgetTester tester) async {
    await pumpActivityCard(
        tester,
        Activity.createNew(
          title: 'title',
          startTime: startTime,
          alarmType: NO_ALARM,
        ));
    expect(find.byIcon(AbiliaIcons.handi_no_alarm_vibration), findsOneWidget);
  });

  testWidgets('icon for reminder ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        reminderBefore: [124],
      ),
    );
    expect(find.byIcon(AbiliaIcons.handi_reminder), findsOneWidget);
  });

  testWidgets('icon for info item ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        infoItem: NoteInfoItem('text'),
      ),
    );
    expect(find.byIcon(AbiliaIcons.handi_info), findsOneWidget);
  });

  testWidgets('icon for private activity ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        secret: true,
      ),
    );
    expect(find.byType(PrivateIcon), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.password_protection), findsOneWidget);
  });

  testWidgets('full day that ha category has no category offset',
      (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        fullDay: true,
        category: Category.right,
      ),
    );
    final animatedcontainer =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(animatedcontainer.margin, EdgeInsets.zero);
  });

  testWidgets('category right has category offset',
      (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        category: Category.right,
      ),
    );
    final animatedcontainer =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(animatedcontainer.margin?.horizontal, greaterThan(0.0));
  });

  testWidgets('category left has category offset', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        category: Category.left,
      ),
    );
    final animatedcontainer =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(animatedcontainer.margin?.horizontal, greaterThan(0.0));
  });

  testWidgets('current activity is not crossed over',
      (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
      ),
    );
    expect(find.byType(CrossOver), findsNothing);
  });

  testWidgets('past activity is crossed over', (WidgetTester tester) async {
    await pumpActivityCard(
        tester,
        Activity.createNew(
          title: 'title',
          startTime: startTime,
        ),
        Occasion.past);
    expect(find.byType(CrossOver), findsOneWidget);
  });

  testWidgets('past activity with image is crossed over',
      (WidgetTester tester) async {
    await pumpActivityCard(
        tester,
        Activity.createNew(
          title: 'title',
          startTime: startTime,
          fileId: Uuid().v4(),
        ),
        Occasion.past);
    tester.takeException();
    expect(find.byType(CrossOver), findsOneWidget);
  });

  testWidgets('past activity with image and is signed off is not crossed over',
      (WidgetTester tester) async {
    await pumpActivityCard(
        tester,
        Activity.createNew(
          title: 'title',
          startTime: startTime,
          fileId: Uuid().v4(),
          checkable: true,
          signedOffDates: [startTime.onlyDays()],
        ),
        Occasion.past);
    tester.takeException();
    expect(find.byType(CrossOver), findsNothing);
  });

  testWidgets('tts', (WidgetTester tester) async {
    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime,
      fileId: Uuid().v4(),
      checkable: true,
      signedOffDates: [startTime.onlyDays()],
    );
    await pumpActivityCard(tester, activity, Occasion.past);
    tester.takeException();
    await tester.verifyTts(find.byType(ActivityCard), contains: activity.title);
  });
}
