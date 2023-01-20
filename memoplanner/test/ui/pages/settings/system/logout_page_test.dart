import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import '../../../../fakes/all.dart';
import '../../../../mocks/mock_bloc.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/app_pumper.dart';

void main() {
  final mockClient = MockBaseClient();
  const dirtyItems = DirtyItems(
    activities: 1,
    activityTemplates: 2,
    timerTemplate: 3,
    photos: 4,
    settingsData: true,
  );
  final translate = Locales.language.values.first;
  final now = DateTime(2020, 01, 01);

  late MockLogoutSyncCubit mockLogoutSyncCubit;
  late MockLastSyncDb mockLastSyncDb;
  late MockSyncBloc mockSyncBloc;
  late LicenseCubit mockLicenseCubit;

  setUpAll(() {
    if (Config.isMP) {
      layout = const LayoutMedium();
    }
  });

  setUp(() async {
    await initializeDateFormatting();
    mockLogoutSyncCubit = MockLogoutSyncCubit();
    mockLastSyncDb = MockLastSyncDb();
    mockLicenseCubit = MockLicenseCubit();
    mockSyncBloc = MockSyncBloc();

    when(() => mockLogoutSyncCubit.state)
        .thenAnswer((_) => const LogoutSyncState(
              logoutWarning: LogoutWarning.firstWarningSyncFailed,
            ));
    when(() => mockLicenseCubit.validLicense).thenReturn(true);
    when(() => mockLicenseCubit.state).thenReturn(ValidLicense());
    when(() => mockLastSyncDb.getLastSyncTime())
        .thenAnswer((_) => now.subtract(5.days()));
    when(() => mockSyncBloc.state)
        .thenAnswer((_) => SyncedFailed(lastSynced: now.subtract(5.days())));

    GetItInitializer()
      ..sharedPreferences =
          await FakeSharedPreferences.getInstance(loggedIn: false)
      ..activityDb = FakeActivityDb()
      ..fireBasePushService = FakeFirebasePushService()
      ..client = mockClient
      ..fileStorage = FakeFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..database = FakeDatabase()
      ..genericDb = FakeGenericDb()
      ..sessionsDb = FakeSessionsDb()
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..lastSyncDb = mockLastSyncDb
      ..init();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Widget createWarningModal() {
    return MaterialApp(
      supportedLocales: Translator.supportedLocals,
      localizationsDelegates: const [Translator.delegate],
      localeResolutionCallback: (locale, supportedLocales) => supportedLocales
          .firstWhere((l) => l.languageCode == locale?.languageCode,
              orElse: () => supportedLocales.first),
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider<SyncBloc>.value(value: mockSyncBloc),
          BlocProvider<LicenseCubit>.value(value: mockLicenseCubit),
          BlocProvider<ClockBloc>(create: (context) => ClockBloc.fixed(now)),
          BlocProvider<LogoutSyncCubit>.value(value: mockLogoutSyncCubit),
          BlocProvider<SpeechSettingsCubit>(
            create: (context) => FakeSpeechSettingsCubit(),
          ),
          BlocProvider<ConnectivityCubit>(
            create: (context) => FakeConnectivityCubit(),
          ),
        ],
        child: child!,
      ),
      home: const WarningModal(),
    );
  }

  Widget createLogoutPage() {
    return MaterialApp(
      supportedLocales: Translator.supportedLocals,
      localizationsDelegates: const [Translator.delegate],
      localeResolutionCallback: (locale, supportedLocales) => supportedLocales
          .firstWhere((l) => l.languageCode == locale?.languageCode,
              orElse: () => supportedLocales.first),
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider<SyncBloc>.value(value: mockSyncBloc),
          BlocProvider<LicenseCubit>.value(value: mockLicenseCubit),
          BlocProvider<ClockBloc>(create: (context) => ClockBloc.fixed(now)),
          BlocProvider<SpeechSettingsCubit>(
            create: (context) => FakeSpeechSettingsCubit(),
          ),
        ],
        child: child!,
      ),
      home: const LogoutPage(),
    );
  }

  testWidgets('Logout page shows', (WidgetTester tester) async {
    // Act
    await tester.pumpWidgetWithMPSize(createLogoutPage());
    await tester.pumpAndSettle();
    // Assert
    expect(find.byType(LogoutPage), findsOneWidget);
  });

  testWidgets(
      'Pressing logout button without unsynced data does not show warning',
      (WidgetTester tester) async {
    // Arrange
    final mockAuthenticationBloc = MockAuthenticationBloc();
    when(() => mockAuthenticationBloc.add(const LoggedOut()))
        .thenAnswer((_) {});
    when(() => mockSyncBloc.state)
        .thenReturn(const Synced(didFetchData: false));
    when(() => mockSyncBloc.hasDirty()).thenAnswer((_) => Future.value(false));

    // Act
    await tester.pumpWidgetWithMPSize(
      BlocProvider<AuthenticationBloc>.value(
        value: mockAuthenticationBloc,
        child: createLogoutPage(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LogoutButton));
    await tester.pumpAndSettle();
    // Assert
    expect(find.byType(WarningModal), findsNothing);
  });

  group('Warning modal variations', () {
    void verifyLastSyncText() {
      final daysAgo = now.difference(mockLastSyncDb.getLastSyncTime()!);
      final dateString =
          DateFormat.yMd(Translator.supportedLocals.first.languageCode)
              .format(mockLastSyncDb.getLastSyncTime()!.onlyDays());
      final lastSyncString =
          '${translate.lastSyncWas} $dateString (${daysAgo.comparedToNowString(translate, false, daysOnly: true)}).';
      expect(
        find.text(lastSyncString),
        findsOneWidget,
      );
    }

    void verifyLogoutButtonEnabled() {
      expect(
        find.byWidgetPredicate(
          (widget) => widget is LogoutButton && (widget.onPressed != null),
        ),
        findsOneWidget,
      );
    }

    testWidgets('first warning & sync failed', (WidgetTester tester) async {
      // Act
      await tester.pumpWidgetWithMPSize(createWarningModal());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WarningModal), findsOneWidget);
      expect(find.text(translate.goOnlineBeforeLogout), findsOneWidget);
      verifyLastSyncText();
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Icon &&
            widget.icon == AbiliaIcons.noWifi &&
            widget.color == AbiliaColors.red),
        findsOneWidget,
      );
      if (Config.isMPGO) {
        expect(find.text(translate.connectToInternetToLogOut), findsOneWidget);
      } else {
        expect(find.byType(WiFiPickField), findsOneWidget);
      }
      expect(find.byKey(TestKey.dirtyItems), findsNothing);
      verifyLogoutButtonEnabled();
    });

    testWidgets('first warning & syncing', (WidgetTester tester) async {
      // Arrange
      when(() => mockLogoutSyncCubit.state).thenAnswer(
        (_) => const LogoutSyncState(
          logoutWarning: LogoutWarning.firstWarningSyncing,
        ),
      );

      // Act
      await tester.pumpWidgetWithMPSize(createWarningModal());
      await tester.pump(const Duration(milliseconds: 1));

      // Assert
      expect(find.byType(WarningModal), findsOneWidget);
      expect(find.text(translate.goOnlineBeforeLogout), findsOneWidget);
      expect(find.text(translate.syncing), findsOneWidget);
      expect(find.byType(AbiliaProgressIndicator), findsOneWidget);
      if (Config.isMPGO) {
        expect(find.text(translate.connectToInternetToLogOut), findsNothing);
      } else {
        expect(find.byType(WiFiPickField), findsOneWidget);
      }
      expect(find.byKey(TestKey.dirtyItems), findsNothing);
      verifyLogoutButtonEnabled();
    });

    testWidgets('first warning & success', (WidgetTester tester) async {
      // Arrange
      when(() => mockLogoutSyncCubit.state).thenAnswer(
        (_) => const LogoutSyncState(
            logoutWarning: LogoutWarning.firstWarningSuccess),
      );

      // Act
      await tester.pumpWidgetWithMPSize(createWarningModal());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WarningModal), findsOneWidget);
      expect(find.text(translate.allDataSaved), findsOneWidget);
      expect(find.text(translate.canLogOutSafely), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.ok), findsOneWidget);
      expect(find.text(translate.connectToInternetToLogOut), findsNothing);
      expect(find.byType(WiFiPickField), findsNothing);
      expect(find.byKey(TestKey.dirtyItems), findsNothing);
      verifyLogoutButtonEnabled();
    });

    testWidgets('second warning & sync failed', (WidgetTester tester) async {
      // Arrange
      when(() => mockLogoutSyncCubit.state).thenAnswer(
        (_) => const LogoutSyncState(
          logoutWarning: LogoutWarning.secondWarningSyncFailed,
          dirtyItems: dirtyItems,
        ),
      );

      // Act
      await tester.pumpWidgetWithMPSize(createWarningModal());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WarningModal), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.irError), findsOneWidget);
      expect(find.text(translate.doNotLoseYourContent), findsOneWidget);
      verifyLastSyncText();
      expect(find.text(translate.ifYouLogoutYouWillLose), findsOneWidget);
      if (Config.isMPGO) {
        expect(find.text(translate.connectToInternetToLogOut), findsOneWidget);
      } else {
        expect(find.byType(WiFiPickField), findsOneWidget);
      }
      expect(find.text(translate.ifYouLogoutYouWillLose), findsOneWidget);
      expect(find.byKey(TestKey.dirtyItems), findsOneWidget);
      verifyLogoutButtonEnabled();
    });

    testWidgets('second warning & syncing', (WidgetTester tester) async {
      // Arrange
      when(() => mockLogoutSyncCubit.state).thenAnswer(
        (_) => const LogoutSyncState(
          logoutWarning: LogoutWarning.secondWarningSyncing,
          dirtyItems: dirtyItems,
        ),
      );

      // Act
      await tester.pumpWidgetWithMPSize(createWarningModal());
      await tester.pump(const Duration(milliseconds: 1));

      // Assert
      expect(find.byType(WarningModal), findsOneWidget);
      expect(
        find.byKey(TestKey.logoutModalProgressIndicator),
        findsOneWidget,
      );
      expect(find.text(translate.doNotLoseYourContent), findsOneWidget);
      expect(find.text(translate.syncing), findsOneWidget);
      if (Config.isMPGO) {
        expect(find.text(translate.connectToInternetToLogOut), findsNothing);
      } else {
        expect(find.byType(WiFiPickField), findsOneWidget);
      }
      expect(find.text(translate.ifYouLogoutYouWillLose), findsOneWidget);
      expect(find.byKey(TestKey.dirtyItems), findsOneWidget);
      verifyLogoutButtonEnabled();
    });

    testWidgets('second warning & success', (WidgetTester tester) async {
      // Arrange
      when(() => mockLogoutSyncCubit.state).thenAnswer(
        (_) => const LogoutSyncState(
          logoutWarning: LogoutWarning.secondWarningSuccess,
          dirtyItems: dirtyItems,
        ),
      );

      // Act
      await tester.pumpWidgetWithMPSize(createWarningModal());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WarningModal), findsOneWidget);
      expect(find.byKey(TestKey.logoutModalOkIcon), findsOneWidget);
      expect(find.text(translate.allDataSaved), findsOneWidget);
      expect(find.text(translate.canLogOutSafely), findsOneWidget);
      expect(find.text(translate.connectToInternetToLogOut), findsNothing);
      expect(find.byType(WiFiPickField), findsNothing);
      expect(find.text(translate.ifYouLogoutYouWillLose), findsNothing);
      expect(find.byKey(TestKey.dirtyItems), findsOneWidget);
      verifyLogoutButtonEnabled();
    });

    testWidgets('licence has expired', (WidgetTester tester) async {
      // Arrange
      when(() => mockLogoutSyncCubit.state).thenAnswer(
        (_) => const LogoutSyncState(
          logoutWarning: LogoutWarning.licenseExpiredWarning,
          dirtyItems: dirtyItems,
        ),
      );
      when(() => mockLicenseCubit.validLicense).thenReturn(false);

      // Act
      await tester.pumpWidgetWithMPSize(createWarningModal());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WarningModal), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.irError), findsOneWidget);
      expect(find.text(translate.memoplannerLicenseExpired), findsOneWidget);
      expect(find.text(translate.needLicenseToSaveData), findsOneWidget);
      expect(
          find.text(translate.contactProviderToExtendLicense), findsOneWidget);
      expect(find.text(translate.connectToInternetToLogOut), findsNothing);
      expect(find.byType(WiFiPickField), findsNothing);
      expect(find.text(translate.ifYouLogoutYouWillLose), findsOneWidget);
      expect(find.byKey(TestKey.dirtyItems), findsOneWidget);
      verifyLogoutButtonEnabled();
    });
  });
}
