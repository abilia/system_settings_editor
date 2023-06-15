import 'package:flutter_test/flutter_test.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_clock/ticker.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';

void main() {
  late final Lt translate;
  final initialTime = DateTime(2021, 04, 17, 09, 20);
  Iterable<Generic> generics = [];
  late MockGenericDb genericDb;

  setUpAll(() async {
    await Lokalise.initMock();
    translate = await Lt.load(Lt.supportedLocales.first);
  });

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;

    genericDb = MockGenericDb();
    when(() => genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(generics));
    when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => genericDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..ticker = Ticker.fake(initialTime: initialTime)
      ..client = fakeClient(genericResponse: () => generics)
      ..database = FakeDatabase()
      ..genericDb = genericDb
      ..sortableDb = FakeSortableDb()
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(() {
    generics = [];
    GetIt.I.reset();
  });

  group('settings page', () {
    testWidgets('shows', (tester) async {
      await tester.goToFunctionSettingsPage(pump: true);
      expect(find.byType(FunctionSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });

    group('bottom bar tab', () {
      testWidgets('hide add activity saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.plus));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: DisplaySettings.functionMenuDisplayNewActivityKey,
          matcher: isFalse,
        );
      });

      testWidgets('hide week calendar saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.week));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: DisplaySettings.functionMenuDisplayWeekKey,
          matcher: isFalse,
        );
      });

      testWidgets('hide month calendar saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.month));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: DisplaySettings.functionMenuDisplayMonthKey,
          matcher: isFalse,
        );
      });

      testWidgets('hide menu calendar shows popup and saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.appMenu));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(YesButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: DisplaySettings.functionMenuDisplayMenuKey,
          matcher: isFalse,
        );
      });

      testWidgets('all menu item disabled disables menu switch',
          (tester) async {
        generics = [
          MenuSettings.showCameraKey,
          MenuSettings.showPhotosKey,
          MenuSettings.showPhotoCalendarKey,
          MenuSettings.showTemplatesKey,
          MenuSettings.showQuickSettingsKey,
          MenuSettings.showSettingsKey,
        ].map(
          (id) => Generic.createNew<GenericSettingData>(
            data: GenericSettingData.fromData(data: false, identifier: id),
          ),
        );
        await tester.pumpApp();
        expect(find.byType(MenuButton), findsNothing);
        await tester.tap(find.byKey(TestKey.hiddenSettingsButtonLeft));
        await tester.tap(find.byKey(TestKey.hiddenSettingsButtonRight));
        await tester.tap(find.byKey(TestKey.hiddenSettingsButtonLeft));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
        await tester.pumpAndSettle();

        expect(
            tester
                .widget<SwitchField>(
                    find.widgetWithIcon(SwitchField, AbiliaIcons.appMenu))
                .onChanged,
            isNull);

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: DisplaySettings.functionMenuDisplayMenuKey,
          matcher: isTrue,
        );
      });
    });

    group('home button settings tab', () {
      testWidgets('hides home button options when bottom bar hidden ',
          (tester) async {
        // Act - got to home button settings
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.browserHome));
        await tester.pumpAndSettle();
        // Assert -- all radio buttons there
        expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.week), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.month), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.appMenu), findsOneWidget);
        expect(
          find.byIcon(AbiliaIcons.photoCalendar),
          findsOneWidget,
        );

        // Act -- deselect calendars and meny at too bar tag

        await tester
            .tap(find.byIcon(AbiliaIcons.shortcutMenu)); // home setting tab

        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.week));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.month));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.appMenu));
        await tester.pumpAndSettle();
        await tester
            .tap(find.byIcon(AbiliaIcons.browserHome)); // toolbar setting tab
        await tester.pumpAndSettle();
        // Assert -- finds only two radion buttons
        expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.week), findsNothing);
        expect(find.byIcon(AbiliaIcons.month), findsNothing);
        expect(find.byIcon(AbiliaIcons.appMenu), findsNothing);
        expect(
          find.byIcon(AbiliaIcons.photoCalendar),
          findsOneWidget,
        );
      });

      testWidgets('week view choice saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.browserHome));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.week));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: FunctionsSettings.functionMenuStartViewKey,
          matcher: StartView.weekCalendar.index,
        );
      });

      testWidgets('month view choice saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.browserHome));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.month));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: FunctionsSettings.functionMenuStartViewKey,
          matcher: StartView.monthCalendar.index,
        );
      });

      testWidgets('menu view choice saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.browserHome));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.appMenu));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: FunctionsSettings.functionMenuStartViewKey,
          matcher: StartView.menu.index,
        );
      });

      testWidgets('photo view choice saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.browserHome));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.photoCalendar));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: FunctionsSettings.functionMenuStartViewKey,
          matcher: StartView.photoAlbum.index,
        );
      });
    });

    group('inactivity settings tab', () {
      testWidgets('timeout choice saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.restore));
        await tester.pumpAndSettle();

        expect(find.text(translate.noTimeout), findsOneWidget);
        expect(find.text('10 ${translate.minutes}'), findsOneWidget);
        expect(find.text('5 ${translate.minutes}'), findsOneWidget);
        expect(find.text('1 ${translate.minute}'), findsOneWidget);

        await tester.tap(find.text('5 ${translate.minutes}'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: TimeoutSettings.activityTimeoutKey,
          matcher: 5 * 60 * 1000,
        );
      });

      testWidgets('screensaver settings saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.restore));
        await tester.pumpAndSettle();

        expect(
            tester
                .widget<SwitchField>(
                    find.widgetWithIcon(SwitchField, AbiliaIcons.screensaver))
                .onChanged,
            isNull);

        await tester.tap(find.text('5 ${translate.minutes}'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.screensaver));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: TimeoutSettings.useScreensaverKey,
          matcher: isTrue,
        );
      });

      testWidgets('screensaver settings saved as false when no timeout ',
          (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.restore));
        await tester.pumpAndSettle();

        await tester.tap(find.text('5 ${translate.minutes}'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.screensaver));
        await tester.pumpAndSettle();
        await tester.tap(find.text(translate.noTimeout));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: TimeoutSettings.useScreensaverKey,
          matcher: isFalse,
        );
      });
    });

    testWidgets('screensaver only during night saved', (tester) async {
      await tester.goToFunctionSettingsPage(pump: true);
      await tester.tap(find.byIcon(AbiliaIcons.restore));
      await tester.pumpAndSettle();

      await tester.tap(find.text('5 ${translate.minutes}'));
      await tester.pumpAndSettle();

      expect(find.byIcon(AbiliaIcons.screensaverNight), findsNothing);
      await tester.tap(find.byIcon(AbiliaIcons.screensaver));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.screensaverNight));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: TimeoutSettings.screensaverOnlyDuringNightKey,
        matcher: isTrue,
      );
    });

    testWidgets('screensaver only during night false when screensaver is false',
        (tester) async {
      await tester.goToFunctionSettingsPage(pump: true);
      await tester.tap(find.byIcon(AbiliaIcons.restore));
      await tester.pumpAndSettle();

      await tester.tap(find.text('5 ${translate.minutes}'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.screensaver));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.screensaverNight));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.screensaver));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: TimeoutSettings.screensaverOnlyDuringNightKey,
        matcher: isFalse,
      );
    });

    testWidgets('timout settings correct', (tester) async {
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: 5.minutes().inMilliseconds,
            identifier: TimeoutSettings.activityTimeoutKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: true,
            identifier: TimeoutSettings.useScreensaverKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: true,
            identifier: TimeoutSettings.screensaverOnlyDuringNightKey,
          ),
        ),
      ];
      await tester.goToFunctionSettingsPage(pump: true);
      await tester.tap(find.byIcon(AbiliaIcons.restore));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<RadioField<Duration>>(
                find.widgetWithText(RadioField<Duration>, '5 minutes'))
            .groupValue,
        const Duration(minutes: 5),
      );

      expect(
          tester
              .widget<SwitchField>(
                  find.widgetWithIcon(SwitchField, AbiliaIcons.screensaver))
              .value,
          isTrue);
      expect(
          tester
              .widget<SwitchField>(find.widgetWithIcon(
                  SwitchField, AbiliaIcons.screensaverNight))
              .value,
          isTrue);
    });
  }, skip: !Config.isMP);

  group('BottomBar visisbility settings', () {
    testWidgets('Default settings shows all buttons in bottomBar',
        (tester) async {
      // Act
      await tester.pumpApp();

      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AddButton), findsOneWidget);
      expect(find.byType(AbiliaTabs), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.week), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.month), findsOneWidget);
      if (Config.isMP) {
        expect(find.byType(MenuButton), findsOneWidget);
      } else if (Config.isMPGO) {
        expect(find.byType(MpGoMenuButton), findsOneWidget);
      }
    });

    testWidgets('hides AddActivity Button in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: DisplaySettings.functionMenuDisplayNewActivityKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byKey(TestKey.addActivityButton), findsNothing);
      expect(find.byKey(TestKey.addTimerButton), findsOneWidget);
    }, skip: !Config.isMP);

    testWidgets('hides AddTimer Button in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: DisplaySettings.functionMenuDisplayNewTimerKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byKey(TestKey.addActivityButton), findsOneWidget);
      expect(find.byKey(TestKey.addTimerButton), findsNothing);
    }, skip: !Config.isMP);

    testWidgets('hides AddActivity and AddTimer Button in bottomBar',
        (tester) async {
      // Arrange
      generics = [
        DisplaySettings.functionMenuDisplayNewActivityKey,
        DisplaySettings.functionMenuDisplayNewTimerKey,
      ].map(
        (id) => Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(data: false, identifier: id),
        ),
      );
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byKey(TestKey.addActivityButton), findsNothing);
      expect(find.byKey(TestKey.addTimerButton), findsNothing);
    });

    testWidgets('hides Menu Button in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: DisplaySettings.functionMenuDisplayMenuKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(MenuButton), findsNothing);
    });

    testWidgets('hides Week calendar in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: DisplaySettings.functionMenuDisplayWeekKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AbiliaTabs), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.week), findsNothing);
    });

    testWidgets('hides Month calendar in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: DisplaySettings.functionMenuDisplayMonthKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AbiliaTabs), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.month), findsNothing);
    });

    testWidgets('hide Month and week calendar in bottomBar', (tester) async {
      // Arrange
      generics = [
        DisplaySettings.functionMenuDisplayMonthKey,
        DisplaySettings.functionMenuDisplayWeekKey,
      ].map(
        (id) => Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(data: false, identifier: id),
        ),
      );
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AbiliaTabBar), findsNothing);
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.month), findsNothing);
      expect(find.byIcon(AbiliaIcons.week), findsNothing);
    });

    testWidgets(
        'Can change between page in bottom bar (BUG SGC-1488, SGC-1489)',
        (tester) async {
      // Arrange
      generics = [
        DisplaySettings.functionMenuDisplayMonthKey,
        DisplaySettings.functionMenuDisplayWeekKey,
      ].map(
        (id) => Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(data: false, identifier: id),
        ),
      );
      // Act
      await tester.pumpApp();
      // Assert -- There is still a icon with day calendar
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      generics = [
        DisplaySettings.functionMenuDisplayMonthKey,
        DisplaySettings.functionMenuDisplayWeekKey,
      ].map(
        (id) => Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(data: true, identifier: id),
        ),
      );
      await tester.drag(find.byType(CalendarPage), const Offset(0, 500));
      await tester.pumpAndSettle();
      if (Config.isMP) {
        await tester.tap(find.byType(MenuButton));
        await tester.pumpAndSettle();
        // Assert -- Can switch to MenuPage
        expect(find.byType(MenuPage), findsOneWidget);
      }
      if (Config.isMPGO) {
        await tester.tap(find.byType(MpGoMenuButton));
        await tester.pumpAndSettle();
        // Assert -- Can go to MenuPage
        expect(find.byType(MpGoMenuPage), findsOneWidget);
      }
    });

    testWidgets('hides bottomBar', (tester) async {
      // Arrange
      generics = [
        DisplaySettings.functionMenuDisplayMonthKey,
        DisplaySettings.functionMenuDisplayWeekKey,
        DisplaySettings.functionMenuDisplayNewActivityKey,
        DisplaySettings.functionMenuDisplayNewTimerKey,
        DisplaySettings.functionMenuDisplayMenuKey,
      ].map(
        (id) => Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(data: false, identifier: id),
        ),
      );
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsNothing);
    });

    testWidgets('hidden bottomBar shows hidden settings button',
        (tester) async {
      // Arrange
      generics = [
        DisplaySettings.functionMenuDisplayMonthKey,
        DisplaySettings.functionMenuDisplayWeekKey,
        DisplaySettings.functionMenuDisplayNewActivityKey,
        DisplaySettings.functionMenuDisplayNewTimerKey,
        DisplaySettings.functionMenuDisplayMenuKey,
      ].map(
        (id) => Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(data: false, identifier: id),
        ),
      );
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsNothing);
      expect(find.byType(HiddenSetting), findsOneWidget);
      // Act
      await tester.tap(find.byKey(TestKey.hiddenSettingsButtonLeft));
      await tester.tap(find.byKey(TestKey.hiddenSettingsButtonRight));
      await tester.tap(find.byKey(TestKey.hiddenSettingsButtonLeft));
      await tester.pumpAndSettle();
      expect(
        find.byType(SettingsPage),
        findsOneWidget,
      );
    });
  });
}

extension on WidgetTester {
  Future<void> goToFunctionSettingsPage({bool pump = false}) async {
    if (pump) await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.menuSetup));
    await pumpAndSettle();
  }
}
