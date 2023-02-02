import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:uuid/uuid.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/i18n/app_localizations.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:memoplanner/ui/components/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/tts.dart';

void main() {
  final startTime = DateTime(2011, 11, 11, 11, 11);
  final day = DateTime(2011, 11, 11);
  late MockDayEventsCubit dayEventsCubitMock;
  late SupportPersonsRepository supportPersonsRepository;

  const supportPerson = SupportPerson(id: 0, name: 'Test', image: '');

  bool applyCrossOver() =>
      (find.byType(CrossOver).evaluate().first.widget as CrossOver).applyCross;

  setUp(() {
    supportPersonsRepository = MockSupportPersonsRepository();
    when(() => supportPersonsRepository.load())
        .thenAnswer((_) => Future.value({}));
  });

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
                child: RepositoryProvider<SupportPersonsRepository>(
                  create: (context) => supportPersonsRepository,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<AuthenticationBloc>(
                          create: (context) => FakeAuthenticationBloc()),
                      BlocProvider<UserFileCubit>(
                        create: (context) => UserFileCubit(
                          fileStorage: FakeFileStorage(),
                          syncBloc: FakeSyncBloc(),
                          userFileRepository: FakeUserFileRepository(),
                        ),
                      ),
                      BlocProvider<ClockBloc>(
                        create: (context) => ClockBloc.fixed(startTime),
                      ),
                      BlocProvider<DayEventsCubit>(
                        create: (context) => dayEventsCubitMock,
                      ),
                      BlocProvider<MemoplannerSettingsBloc>(
                        create: (context) => FakeMemoplannerSettingsBloc(),
                      ),
                      BlocProvider<SpeechSettingsCubit>(
                        create: (context) => FakeSpeechSettingsCubit(),
                      ),
                      BlocProvider<SupportPersonsCubit>(
                        create: (context) => SupportPersonsCubit(
                          supportPersonsRepository:
                              context.read<SupportPersonsRepository>(),
                        )..load(),
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
            ),
          )
          .then((_) => tester.pumpAndSettle());

  setUp(() async {
    setupFakeTts();
    dayEventsCubitMock = MockDayEventsCubit();
    await initializeDateFormatting();

    final expected = EventsState(
      activities: const [],
      timers: const [],
      fullDayActivities: const [],
      day: day,
      occasion: Occasion.current,
    );

    when(() => dayEventsCubitMock.state).thenReturn(expected);
    when(() => dayEventsCubitMock.stream)
        .thenAnswer((_) => Stream.fromIterable([expected]));

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

  group('Icons', () {
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

    testWidgets('icon for no alarm nor vibration ',
        (WidgetTester tester) async {
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
    group('Available for', () {
      testWidgets('Only me', (WidgetTester tester) async {
        when(() => supportPersonsRepository.load())
            .thenAnswer((_) => Future.value({supportPerson}));
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

      testWidgets('All my support persons', (WidgetTester tester) async {
        when(() => supportPersonsRepository.load())
            .thenAnswer((_) => Future.value({supportPerson}));
        await pumpActivityCard(
          tester,
          Activity.createNew(
            title: 'title',
            startTime: startTime,
            secret: false,
          ),
        );
        expect(find.byType(AvailableForIcon), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.unlock), findsOneWidget);
      });

      testWidgets('Selected support persons', (WidgetTester tester) async {
        when(() => supportPersonsRepository.load())
            .thenAnswer((_) => Future.value({supportPerson}));
        await pumpActivityCard(
          tester,
          Activity.createNew(
            title: 'title',
            startTime: startTime,
            secret: true,
            secretExemptions: const {0},
          ),
        );
        expect(find.byType(AvailableForIcon), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.selectedSupport), findsOneWidget);
      });

      testWidgets(
          'No available for icon is shown if user has no support persons',
          (WidgetTester tester) async {
        await pumpActivityCard(
          tester,
          Activity.createNew(
            title: 'title',
            startTime: startTime,
            secret: true,
          ),
        );
        expect(find.byType(AvailableForIcon), findsNothing);
      });
    });
  });
}
