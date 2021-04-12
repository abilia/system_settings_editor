import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../mocks.dart';

void main() {
  final translate = Locales.language.values.first;
  final initialTime = DateTime(2021, 04, 17, 09, 20);
  Iterable<Generic> generics = [];
  GenericDb genericDb;

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    final mockBatch = MockBatch();
    when(mockBatch.commit()).thenAnswer((realInvocation) => Future.value([]));
    final db = MockDatabase();
    when(db.batch()).thenReturn(mockBatch);
    when(db.rawQuery(any)).thenAnswer((realInvocation) => Future.value([]));

    genericDb = MockGenericDb();
    when(genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(generics));
    when(genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(genericDb.insertAndAddDirty(any))
        .thenAnswer((realInvocation) => Future.value([]));

    GetItInitializer()
      ..sharedPreferences = await MockSharedPreferences.getInstance()
      ..ticker = Ticker(
        stream: StreamController<DateTime>().stream,
        initialTime: initialTime,
      )
      ..client = Fakes.client(genericResponse: () => generics)
      ..alarmScheduler = noAlarmScheduler
      ..database = db
      ..syncDelay = SyncDelays.zero
      ..genericDb = genericDb
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('settings page', () {
    testWidgets('shows', (tester) async {
      await tester.goToFunctionSettingsPage(pump: true);
      expect(find.byType(FunctionSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });

    Future _verifySaved(
      WidgetTester tester, {
      String key,
      dynamic matcher,
    }) async {
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      final v = verify(genericDb.insertAndAddDirty(captureAny));
      expect(v.callCount, 1);
      final l = v.captured.single.toList() as List<Generic<GenericData>>;
      final d = l
          .whereType<Generic<MemoplannerSettingData>>()
          .firstWhere((element) => element.data.identifier == key);
      expect(d.data.data, matcher);
    }

    group('bottom bar tab', () {
      testWidgets('hide add activity saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.plus));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.functionMenuDisplayNewActivityKey,
          matcher: isFalse,
        );
      });

      testWidgets('hide week calendar saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.week));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.functionMenuDisplayWeekKey,
          matcher: isFalse,
        );
      });

      testWidgets('hide month calendar saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.month));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.functionMenuDisplayMonthKey,
          matcher: isFalse,
        );
      });

      testWidgets('hide menu calendar saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.app_menu));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.functionMenuDisplayMenuKey,
          matcher: isFalse,
        );
      });
    });
    group('home button settings tab', () {
      testWidgets('hides home button options when bottom bar hidden ',
          (tester) async {
        // Act - got to home button settings
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.browser_home));
        await tester.pumpAndSettle();
        // Assert -- all radio buttons there
        expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.week), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.month), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.app_menu), findsOneWidget);
        expect(
          find.byIcon(AbiliaIcons.past_picture_from_windows_clipboard),
          findsOneWidget,
        );

        // Act -- deselect calendars and meny at too bar tag

        await tester
            .tap(find.byIcon(AbiliaIcons.shortcut_menu)); // home setting tab

        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.week));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.month));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.app_menu));
        await tester.pumpAndSettle();
        await tester
            .tap(find.byIcon(AbiliaIcons.browser_home)); // toolbar setting tab
        await tester.pumpAndSettle();
        // Assert -- finds only two radion buttons
        expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.week), findsNothing);
        expect(find.byIcon(AbiliaIcons.month), findsNothing);
        expect(find.byIcon(AbiliaIcons.app_menu), findsNothing);
        expect(
          find.byIcon(AbiliaIcons.past_picture_from_windows_clipboard),
          findsOneWidget,
        );
      });

      testWidgets('week view choice saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.browser_home));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.week));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.functionMenuStartViewKey,
          matcher: StartView.weekCalendar.index,
        );
      });

      testWidgets('month view choice saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.browser_home));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.month));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.functionMenuStartViewKey,
          matcher: StartView.monthCalendar.index,
        );
      });

      testWidgets('menu view choice saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.browser_home));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.app_menu));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.functionMenuStartViewKey,
          matcher: StartView.menu.index,
        );
      });

      testWidgets('photo view choice saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.browser_home));
        await tester.pumpAndSettle();
        await tester
            .tap(find.byIcon(AbiliaIcons.past_picture_from_windows_clipboard));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.functionMenuStartViewKey,
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

        await _verifySaved(
          tester,
          key: MemoplannerSettings.activityTimeoutKey,
          matcher: 5 * 60 * 1000,
        );
      });
      testWidgets('screen saver settings saved', (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.restore));
        await tester.pumpAndSettle();

        await tester.tap(find.text('5 ${translate.minutes}'));
        await tester.pumpAndSettle();
        await tester
            .tap(find.byIcon(AbiliaIcons.past_picture_from_windows_clipboard));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.useScreensaverKey,
          matcher: isTrue,
        );
      });

      testWidgets('screen saver settings saved as false when no timeout ',
          (tester) async {
        await tester.goToFunctionSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.restore));
        await tester.pumpAndSettle();

        await tester.tap(find.text('5 ${translate.minutes}'));
        await tester.pumpAndSettle();
        await tester
            .tap(find.byIcon(AbiliaIcons.past_picture_from_windows_clipboard));
        await tester.pumpAndSettle();
        await tester.tap(find.text(translate.noTimeout));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.useScreensaverKey,
          matcher: isFalse,
        );
      });
    });
  });
  group('BottomBar visisbility settings', () {
    testWidgets('Default settings shows all buttons in bottomBar',
        (tester) async {
      // Act
      await tester.pumpApp();

      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AddActivityButton), findsOneWidget);
      expect(find.byType(AbiliaTabBar), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.week), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.month), findsOneWidget);
      expect(find.byType(MenuButton), findsOneWidget);
    });

    testWidgets('hides AddActivity Button in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.functionMenuDisplayNewActivityKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AddActivityButton), findsNothing);
    });

    testWidgets('hides Menu Button in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.functionMenuDisplayMenuKey,
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
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.functionMenuDisplayWeekKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AbiliaTabBar), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.week), findsNothing);
    });

    testWidgets('hides Month calendar in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.functionMenuDisplayMonthKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AbiliaTabBar), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.month), findsNothing);
    });

    testWidgets('hide Month and week calendar in bottomBar', (tester) async {
      // Arrange
      generics = [
        MemoplannerSettings.functionMenuDisplayMonthKey,
        MemoplannerSettings.functionMenuDisplayWeekKey,
      ].map(
        (id) => Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(data: false, identifier: id),
        ),
      );
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AbiliaTabBar), findsNothing);
      expect(find.byIcon(AbiliaIcons.month), findsNothing);
      expect(find.byIcon(AbiliaIcons.week), findsNothing);
    });

    testWidgets('hides bottomBar', (tester) async {
      // Arrange
      generics = [
        MemoplannerSettings.functionMenuDisplayMonthKey,
        MemoplannerSettings.functionMenuDisplayWeekKey,
        MemoplannerSettings.functionMenuDisplayNewActivityKey,
        MemoplannerSettings.functionMenuDisplayMenuKey,
      ].map(
        (id) => Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(data: false, identifier: id),
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
        MemoplannerSettings.functionMenuDisplayMonthKey,
        MemoplannerSettings.functionMenuDisplayWeekKey,
        MemoplannerSettings.functionMenuDisplayNewActivityKey,
        MemoplannerSettings.functionMenuDisplayMenuKey,
      ].map(
        (id) => Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(data: false, identifier: id),
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
      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });
}

extension on WidgetTester {
  Future<void> pumpApp() async {
    await pumpWidget(App());
    await pumpAndSettle();
  }

  Future<void> goToFunctionSettingsPage({bool pump = false}) async {
    if (pump) await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.menu_setup));
    await pumpAndSettle();
  }
}
