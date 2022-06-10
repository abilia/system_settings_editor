import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:seagull/repository/all.dart';
import 'package:uuid/uuid.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';

import '../../../fakes/all.dart';
import '../../../test_helpers/tts.dart';

void main() {
  final startTime = DateTime(2011, 11, 11, 11, 11);

  bool applyCrossOver() =>
      (find.byType(CrossOver).evaluate().first.widget as CrossOver).applyCross;

  Future pumpActivityCard(
    WidgetTester tester,
    Activity activity, [
    Occasion? occasion,
  ]) =>
      tester
          .pumpWidget(
            MaterialApp(
              supportedLocales: Translator.supportedLocals,
              localizationsDelegates: const [Translator.delegate],
              localeResolutionCallback: (locale, supportedLocales) =>
                  supportedLocales.firstWhere(
                      (l) => l.languageCode == locale?.languageCode,
                      orElse: () => supportedLocales.first),
              home: RepositoryProvider<UserRepository>(
                create: (context) => FakeUserRepository(),
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<AuthenticationBloc>(
                        create: (context) => FakeAuthenticationBloc()),
                    BlocProvider<UserFileCubit>(
                      create: (context) => UserFileCubit(
                        fileStorage: FakeFileStorage(),
                        pushCubit: FakePushCubit(),
                        syncBloc: FakeSyncBloc(),
                        userFileRepository: FakeUserFileRepository(),
                      ),
                    ),
                    BlocProvider<ClockBloc>(
                      create: (context) => ClockBloc.fixed(startTime),
                    ),
                    BlocProvider<SettingsCubit>(
                      create: (context) => SettingsCubit(
                        settingsDb: FakeSettingsDb(),
                      ),
                    ),
                  ],
                  child: Material(
                    child: ActivityCard(
                      activityOccasion: ActivityOccasion(
                        activity,
                        activity.startTime.onlyDays(),
                        occasion ?? Occasion.current,
                      ),
                    ),
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
    const title = 'title';
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
    expect(find.byType(EventImage), findsNothing);
  });

  testWidgets('has image ', (WidgetTester tester) async {
    await mockNetworkImages(() async {
      await pumpActivityCard(
        tester,
        Activity.createNew(
          title: '',
          fileId: 'fileid',
          startTime: startTime,
        ),
      );

      // Assert image
      expect(find.byType(ActivityCard), findsOneWidget);
      expect(find.byType(EventImage), findsOneWidget);
    });
  });

  testWidgets('has title and image ', (WidgetTester tester) async {
    const title = 'title';
    await mockNetworkImages(() async {
      await pumpActivityCard(
        tester,
        Activity.createNew(
          title: title,
          fileId: 'fileid',
          startTime: startTime,
        ),
      );

      // Assert title and image
      expect(find.byType(ActivityCard), findsOneWidget);
      expect(find.text(title), findsOneWidget);
      expect(find.byType(EventImage), findsOneWidget);
    });
  });

  testWidgets('icon for checkable activity', (WidgetTester tester) async {
    await pumpActivityCard(
        tester,
        Activity.createNew(
            title: 'title', startTime: startTime, checkable: true));

    // Assert title no image
    expect(find.byIcon(AbiliaIcons.handiCheck), findsOneWidget);
  });
  testWidgets('icon for alarm and vibration ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        alarmType: alarmSoundAndVibration,
      ),
    );
    expect(find.byIcon(AbiliaIcons.handiAlarmVibration), findsOneWidget);
  });

  testWidgets('icon for vibration ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        alarmType: alarmVibration,
      ),
    );
    expect(find.byIcon(AbiliaIcons.handiVibration), findsOneWidget);
  });

  testWidgets('icon for no alarm nor vibration ', (WidgetTester tester) async {
    await pumpActivityCard(
        tester,
        Activity.createNew(
          title: 'title',
          startTime: startTime,
          alarmType: noAlarm,
        ));
    expect(find.byIcon(AbiliaIcons.handiNoAlarmVibration), findsOneWidget);
  });

  testWidgets('icon for reminder ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        reminderBefore: const [124],
      ),
    );
    expect(find.byIcon(AbiliaIcons.handiReminder), findsOneWidget);
  });

  testWidgets('icon for info item ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        infoItem: const NoteInfoItem('text'),
      ),
    );
    expect(find.byIcon(AbiliaIcons.handiInfo), findsOneWidget);
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
    expect(find.byType(AvailableForIcon), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.lock), findsOneWidget);
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
    expect(applyCrossOver(), true);
  });

  testWidgets('past activity with image is crossed over',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      await pumpActivityCard(
          tester,
          Activity.createNew(
            title: 'title',
            startTime: startTime,
            fileId: const Uuid().v4(),
          ),
          Occasion.past);

      expect(applyCrossOver(), true);
    });
  });

  testWidgets('past activity with image and is signed off is crossed over',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      await pumpActivityCard(
          tester,
          Activity.createNew(
            title: 'title',
            startTime: startTime,
            fileId: const Uuid().v4(),
            checkable: true,
            signedOffDates: [startTime].map(whaleDateFormat),
          ),
          Occasion.past);

      expect(applyCrossOver(), true);
    });
  });

  testWidgets('tts', (WidgetTester tester) async {
    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime,
      fileId: const Uuid().v4(),
      checkable: true,
      signedOffDates: [startTime].map(whaleDateFormat),
    );
    await mockNetworkImages(() async {
      await pumpActivityCard(tester, activity, Occasion.past);
      await tester.verifyTts(find.byType(ActivityCard),
          contains: activity.title);
    });
  });
}
