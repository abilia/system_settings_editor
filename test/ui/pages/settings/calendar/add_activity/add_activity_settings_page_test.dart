import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/calendar/add_activity/add_activity_general_settings_tab.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/shared.mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';
import '../../../../../test_helpers/verify_generic.dart';

void main() {
  group('New activity settings page', () {
    final translate = Locales.language.values.first;
    final initialTime = DateTime(2021, 04, 17, 09, 20);
    Iterable<Generic> generics = [];
    late MockGenericDb genericDb;

    setUp(() async {
      setupPermissions();
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
      scheduleAlarmNotificationsIsolated = noAlarmScheduler;

      genericDb = MockGenericDb();
      when(genericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value(generics));
      when(genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
      when(genericDb.insertAndAddDirty(any))
          .thenAnswer((_) => Future.value(true));

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..ticker = Ticker(
          stream: StreamController<DateTime>().stream,
          initialTime: initialTime,
        )
        ..client = Fakes.client(genericResponse: () => generics)
        ..database = FakeDatabase()
        ..syncDelay = SyncDelays.zero
        ..genericDb = genericDb
        ..init();
    });

    tearDown(GetIt.I.reset);

    testWidgets('Navigate to page', (tester) async {
      await tester.goToNewActivitySettingsPage();
      expect(find.byType(AddActivitySettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });

    group('General tab', () {
      testWidgets('Allow passed start time', (tester) async {
        await tester.goToNewActivitySettingsPage();
        await tester.tap(find.text(translate.allowPassedStartTime));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.activityTimeBeforeCurrentKey,
          matcher: isFalse,
        );
      });

      testWidgets('Add recurring activity', (tester) async {
        await tester.goToNewActivitySettingsPage();
        await tester.tap(find.text(translate.addRecurringActivity));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.activityRecurringEditableKey,
          matcher: isFalse,
        );
      });

      testWidgets('Show end time', (tester) async {
        await tester.goToNewActivitySettingsPage();
        await tester.tap(find.text(translate.showEndTime));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.activityEndTimeEditableKey,
          matcher: isFalse,
        );
      });

      testWidgets('show alarm', (tester) async {
        await tester.goToNewActivitySettingsPage();
        await tester.tap(find.text(translate.showAlarm));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.activityDisplayAlarmOptionKey,
          matcher: isFalse,
        );
      });

      testWidgets('Show silent alarm', (tester) async {
        await tester.goToNewActivitySettingsPage();
        await tester.tap(find.text(translate.showSilentAlarm));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.activityDisplaySilentAlarmOptionKey,
          matcher: isFalse,
        );
      });

      testWidgets('Show no alarm', (tester) async {
        await tester.goToNewActivitySettingsPage();
        await tester.dragUntilVisible(find.text(translate.showNoAlarm),
            find.byType(AddActivityGeneralSettingsTab), Offset(0, 100));
        await tester.pumpAndSettle();
        await tester.tap(find.text(translate.showNoAlarm));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.activityDisplayNoAlarmOptionKey,
          matcher: isFalse,
        );
      });
    });
    group('Add tab', () {
      testWidgets('Select add type', (tester) async {
        await tester.goToAddTab();
        expect(find.byType(AddActivityAddSettingsTab), findsOneWidget);
        await tester.tap(find.text(translate.stepByStep));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.addActivityTypeAdvancedKey,
          matcher: isFalse,
        );
      });

      testWidgets('Advanced - Set select date', (tester) async {
        await tester.verifyInAddTab(
          find.text(translate.selectDate),
          genericDb,
          key: MemoplannerSettings.activityDateEditableKey,
          matcher: isFalse,
        );
      });

      testWidgets('Advanced - Set select type', (tester) async {
        await tester.verifyInAddTab(
          find.text(translate.selectType),
          genericDb,
          key: MemoplannerSettings.activityTypeEditableKey,
          matcher: isFalse,
        );
      });

      testWidgets('Advanced - Show basic activities', (tester) async {
        await tester.verifyInAddTab(
          find.text(translate.showBasicActivities),
          genericDb,
          key: MemoplannerSettings.advancedActivityTemplateKey,
          matcher: isFalse,
        );
      });

      testWidgets('StepByStep - Show basic activities', (tester) async {
        await tester.verifyStepByStep(
          find.text(translate.showBasicActivities),
          genericDb,
          key: MemoplannerSettings.wizardTemplateStepKey,
          matcher: isFalse,
        );
      });

      testWidgets('StepByStep - Select name', (tester) async {
        await tester.verifyStepByStep(
          find.text(translate.selectName),
          genericDb,
          key: MemoplannerSettings.wizardTitleStepKey,
          matcher: isFalse,
        );
      });

      testWidgets('StepByStep - Select image', (tester) async {
        await tester.verifyStepByStep(
          find.text(translate.selectImage),
          genericDb,
          key: MemoplannerSettings.wizardImageStepKey,
          matcher: isFalse,
        );
      });

      testWidgets('StepByStep - Select date', (tester) async {
        await tester.verifyStepByStep(
          find.text(translate.selectDate),
          genericDb,
          key: MemoplannerSettings.wizardDatePickerStepKey,
          matcher: isFalse,
        );
      });

      testWidgets('StepByStep - Select type', (tester) async {
        await tester.verifyStepByStep(
          find.text(translate.selectImage),
          genericDb,
          key: MemoplannerSettings.wizardTypeStepKey,
          matcher: isFalse,
        );
      });

      testWidgets('StepByStep - Select checkable', (tester) async {
        await tester.verifyStepByStep(
          find.byIcon(AbiliaIcons.handi_check, skipOffstage: false),
          genericDb,
          key: MemoplannerSettings.wizardCheckableStepKey,
          matcher: isFalse,
        );
      });

      testWidgets('StepByStep - Select available for', (tester) async {
        await tester.verifyStepByStep(
          find.text(translate.selectAvailableFor, skipOffstage: false),
          genericDb,
          key: MemoplannerSettings.wizardAvailabilityTypeKey,
          matcher: isFalse,
        );
      });

      testWidgets('StepByStep - Select delete after', (tester) async {
        await tester.verifyStepByStep(
          find.text(translate.selectDeleteAfter, skipOffstage: false),
          genericDb,
          key: MemoplannerSettings.wizardRemoveAfterStepKey,
          matcher: isTrue,
        );
      });

      testWidgets('StepByStep - Select alarm', (tester) async {
        await tester.verifyStepByStep(
          find.text(translate.selectAlarm, skipOffstage: false),
          genericDb,
          key: MemoplannerSettings.wizardAlarmStepKey,
          matcher: isTrue,
        );
      });

      testWidgets('StepByStep - Select checklist', (tester) async {
        await tester.verifyStepByStep(
          find.text(translate.selectChecklist, skipOffstage: false),
          genericDb,
          key: MemoplannerSettings.wizardChecklistStepKey,
          matcher: isTrue,
        );
      });

      testWidgets('StepByStep - Select note', (tester) async {
        await tester.verifyStepByStep(
          find.text(translate.selectNote, skipOffstage: false),
          genericDb,
          key: MemoplannerSettings.wizardNotesStepKey,
          matcher: isTrue,
        );
      });

      testWidgets('StepByStep - Select reminder', (tester) async {
        await tester.verifyStepByStep(
          find.text(translate.selectReminder, skipOffstage: false),
          genericDb,
          key: MemoplannerSettings.wizardRemindersStepKey,
          matcher: isTrue,
        );
      });
    });
    group('Defaults tab', () {
      testWidgets('Select vibration', (tester) async {
        await tester.goToDefaultsTab();
        expect(find.byType(AddActivityDefaultSettingsTab), findsOneWidget);
        await tester.tap(find.text(translate.vibration));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.activityDefaultAlarmTypeKey,
          matcher: ALARM_VIBRATION,
        );
      });

      testWidgets('Select silent only at start', (tester) async {
        await tester.goToDefaultsTab();
        expect(find.byType(AddActivityDefaultSettingsTab), findsOneWidget);
        await tester.tap(find.text(translate.silentAlarm));
        await tester.pumpAndSettle();
        await tester.tap(find.text(translate.alarmOnlyAtStartTime));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.activityDefaultAlarmTypeKey,
          matcher: ALARM_SILENT_ONLY_ON_START,
        );
      });
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future<void> verifyInAddTab(
    Finder f,
    MockGenericDb genericDb, {
    required String key,
    required dynamic matcher,
  }) async {
    await goToAddTab();
    await tap(f);
    await pumpAndSettle();
    await tap(find.byType(OkButton));
    await pumpAndSettle();

    verifySyncGeneric(
      this,
      genericDb,
      key: key,
      matcher: matcher,
    );
  }

  Future<void> verifyStepByStep(
    Finder finder,
    MockGenericDb genericDb, {
    required String key,
    required dynamic matcher,
  }) async {
    await goToAddTab();
    await tap(find.text(Locales.language.values.first.stepByStep));
    await pumpAndSettle();
    expect(find.byType(AddActivityAddSettingsTab), findsOneWidget);
    await dragUntilVisible(
        finder, find.byType(AddActivityAddSettingsTab), Offset(0, -100));
    await pumpAndSettle();
    await tap(finder);
    await pumpAndSettle();
    await tap(find.byType(OkButton));
    await pumpAndSettle();

    verifySyncGeneric(
      this,
      genericDb,
      key: key,
      matcher: matcher,
    );
  }

  Future<void> goToAddTab() async {
    await goToNewActivitySettingsPage();
    await tap(find.byKey(TestKey.addSettingsTab));
    await pumpAndSettle();
  }

  Future<void> goToDefaultsTab() async {
    await goToNewActivitySettingsPage();
    await tap(find.byIcon(AbiliaIcons.technical_settings));
    await pumpAndSettle();
  }

  Future<void> goToNewActivitySettingsPage() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.new_icon));
    await pumpAndSettle();
  }
}
