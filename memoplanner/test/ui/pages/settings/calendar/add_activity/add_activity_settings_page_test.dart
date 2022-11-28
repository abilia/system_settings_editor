import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';
import '../../../../../test_helpers/verify_generic.dart';

void main() {
  group('New activity settings page -', () {
    final translate = Locales.language.values.first;
    final initialTime = DateTime(2021, 04, 17, 09, 20);
    Iterable<Generic> generics = [];
    late MockGenericDb genericDb;

    setUp(() async {
      setupPermissions();
      notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
      scheduleAlarmNotificationsIsolated = noAlarmScheduler;

      genericDb = MockGenericDb();
      when(() => genericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value(generics));
      when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
      when(() => genericDb.insertAndAddDirty(any()))
          .thenAnswer((_) => Future.value(true));

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..ticker = Ticker.fake(initialTime: initialTime)
        ..client = Fakes.client(genericResponse: () => generics)
        ..database = FakeDatabase()
        ..genericDb = genericDb
        ..battery = FakeBattery()
        ..deviceDb = FakeDeviceDb()
        ..init();
    });

    tearDown(() {
      GetIt.I.reset();
      generics = [];
    });

    testWidgets('Navigate to page', (tester) async {
      await tester.goToNewActivitySettingsPage();
      expect(find.byType(AddActivitySettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });

    testWidgets('BUG SGC-1564 Has ScrollArrows', (tester) async {
      await tester.goToNewActivitySettingsPage();
      expect(find.byType(ScrollArrows), findsOneWidget);
    });

    group('General tab -', () {
      testWidgets('Allow passed start time', (tester) async {
        await tester.goToNewActivitySettingsPage();
        await tester.tap(find.text(translate.allowPassedStartTime));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: GeneralAddActivitySettings.allowPassedStartTimeKey,
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
          key: GeneralAddActivitySettings.addRecurringActivityKey,
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
          key: GeneralAddActivitySettings.showEndTimeKey,
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
          key: GeneralAddActivitySettings.showAlarmKey,
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
          key: GeneralAddActivitySettings.showSilentAlarmKey,
          matcher: isFalse,
        );
      });

      testWidgets('Show no alarm', (tester) async {
        await tester.goToNewActivitySettingsPage();
        await tester.dragUntilVisible(find.text(translate.showNoAlarm),
            find.byType(AddActivityGeneralSettingsTab), const Offset(0, 100));
        await tester.pumpAndSettle();
        await tester.tap(find.text(translate.showNoAlarm));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: GeneralAddActivitySettings.showNoAlarmKey,
          matcher: isFalse,
        );
      });

      testWidgets('Show alarm only at start time', (tester) async {
        await tester.goToNewActivitySettingsPage();
        await tester.tap(find.text(translate.showAlarmOnlyAtStartTime));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: GeneralAddActivitySettings.showAlarmOnlyAtStartKey,
          matcher: isFalse,
        );
      });

      testWidgets('Show speech at alarm', (tester) async {
        await tester.goToNewActivitySettingsPage();
        await tester.tap(find.text(translate.showSpeechAtAlarm));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: GeneralAddActivitySettings.showSpeechAtAlarmKey,
          matcher: isFalse,
        );
      });
    });

    group('Add tab -', () {
      testWidgets('Edit view default settings', (tester) async {
        await tester.goToAddTab();
        await tester.tap(find.text(translate.throughEditView));
        await tester.pumpAndSettle();

        final keys = [
          TestKey.showTemplatesSwitch,
          TestKey.addActivitySelectNameSwitch,
          TestKey.addActivitySelectImageSwitch,
          TestKey.addActivitySelectDateSwitch,
          TestKey.addActivitySelectAllDaySwitch,
          TestKey.addActivitySelectCheckableSwitch,
          TestKey.addActivityDeleteAfterSwitch,
          TestKey.addActivitySelectAvailableForSwitch,
          TestKey.addActivitySelectAlarmSwitch,
          TestKey.addActivitySelectReminderSwitch,
          TestKey.addActivitySelectChecklistSwitch,
          TestKey.addActivitySelectNoteSwitch
        ];

        for (Key key in keys) {
          final switchField = tester.widget<SwitchField>(find.byKey(key));
          expect(switchField.value, true);
        }
      });

      testWidgets('Step by step default settings', (tester) async {
        await tester.goToAddTab();
        await tester.tap(find.text(translate.stepByStep));
        await tester.pumpAndSettle();

        final keys = [
          TestKey.showTemplatesSwitch,
          TestKey.addActivitySelectNameSwitch,
          TestKey.addActivitySelectImageSwitch,
          TestKey.addActivitySelectDateSwitch,
          TestKey.addActivitySelectAllDaySwitch,
          TestKey.addActivitySelectCheckableSwitch,
          TestKey.addActivityDeleteAfterSwitch,
          TestKey.addActivitySelectAvailableForSwitch,
          TestKey.addActivitySelectAlarmSwitch,
          TestKey.addActivitySelectReminderSwitch,
          TestKey.addActivitySelectChecklistSwitch,
          TestKey.addActivitySelectNoteSwitch
        ];

        for (Key key in keys) {
          final switchField = tester.widget<SwitchField>(find.byKey(key));
          expect(switchField.value, true);
        }
      });

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
          key: AddActivitySettings.addActivityTypeAdvancedKey,
          matcher: isFalse,
        );
      });

      group('Advanced -', () {
        testWidgets('deselect Show basic activities', (tester) async {
          await tester.verifyInAddTab(
            find.byIcon(AbiliaIcons.basicActivity),
            genericDb,
            key: EditActivitySettings.templateKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select name', (tester) async {
          await tester.verifyInAddTab(
            find.text(translate.selectName),
            genericDb,
            key: EditActivitySettings.titleKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select image', (tester) async {
          await tester.verifyInAddTab(
            find.text(translate.selectImage),
            genericDb,
            key: EditActivitySettings.imageKey,
            matcher: isFalse,
          );
        });

        testWidgets('can not deselect basic, name and image', (tester) async {
          await tester.goToAddTab();
          await tester.tap(find.byIcon(AbiliaIcons.basicActivity));
          await tester.pumpAndSettle();
          await tester.tap(find.text(translate.selectName));
          await tester.pumpAndSettle();
          await tester.tap(find.text(translate.selectImage));
          await tester.pumpAndSettle();
          expect(find.byType(ErrorDialog), findsOneWidget);
        });

        testWidgets('deselect Select date', (tester) async {
          await tester.verifyInAddTab(
            find.text(translate.selectDate),
            genericDb,
            key: EditActivitySettings.dateKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Checkable', (tester) async {
          await tester.verifyInAddTab(
            find.text(translate.selectCheckable),
            genericDb,
            key: EditActivitySettings.checkableKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Available for', (tester) async {
          await tester.verifyInAddTab(
            find.text(translate.selectAvailableFor),
            genericDb,
            key: EditActivitySettings.availabilityKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Delete after', (tester) async {
          await tester.verifyInAddTab(
            find.text(translate.deleteAfter),
            genericDb,
            key: EditActivitySettings.removeAfterKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Alarm', (tester) async {
          await tester.verifyInAddTab(
            find.text(translate.selectAlarm),
            genericDb,
            key: EditActivitySettings.alarmKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Checklist', (tester) async {
          await tester.verifyInAddTab(
            find.text(translate.selectChecklist),
            genericDb,
            key: EditActivitySettings.checklistKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Note', (tester) async {
          await tester.verifyInAddTab(
            find.text(translate.selectNote),
            genericDb,
            key: EditActivitySettings.notesKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Reminder', (tester) async {
          await tester.verifyInAddTab(
            find.text(translate.selectReminder),
            genericDb,
            key: EditActivitySettings.remindersKey,
            matcher: isFalse,
          );
        });
      });

      group('Step-by-step -', () {
        testWidgets('deselect Show basic activities', (tester) async {
          await tester.verifyStepByStep(
            find.text(translate.showTemplates),
            genericDb,
            key: StepByStepSettings.templateKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select name', (tester) async {
          await tester.verifyStepByStep(
            find.text(translate.selectName),
            genericDb,
            key: StepByStepSettings.titleKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select image', (tester) async {
          await tester.verifyStepByStep(
            find.text(translate.selectImage),
            genericDb,
            key: StepByStepSettings.imageKey,
            matcher: isFalse,
          );
        });

        testWidgets('can not deselect basic, name and image', (tester) async {
          await tester.goToAddTab();
          await tester.tap(find.text(translate.stepByStep));
          await tester.pumpAndSettle();
          await tester.tap(find.text(translate.selectImage));
          await tester.pumpAndSettle();
          await tester.tap(find.text(translate.selectName));
          await tester.pumpAndSettle();
          await tester.tap(find.text(translate.showTemplates));
          await tester.pumpAndSettle();
          expect(find.byType(ErrorDialog), findsOneWidget);
        });

        testWidgets('deselect Select date', (tester) async {
          await tester.verifyStepByStep(
            find.text(translate.selectDate),
            genericDb,
            key: StepByStepSettings.dateKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select full day', (tester) async {
          await tester.verifyStepByStep(
            find.text(translate.selectAllDay),
            genericDb,
            key: StepByStepSettings.fullDayKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select checkable', (tester) async {
          await tester.verifyStepByStep(
            find.byIcon(AbiliaIcons.handiCheck, skipOffstage: false),
            genericDb,
            key: StepByStepSettings.checkableKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select available for', (tester) async {
          await tester.verifyStepByStep(
            find.text(translate.selectAvailableFor, skipOffstage: false),
            genericDb,
            key: StepByStepSettings.availabilityKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select delete after', (tester) async {
          await tester.verifyStepByStep(
            find.text(translate.deleteAfter, skipOffstage: false),
            genericDb,
            key: StepByStepSettings.removeAfterKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select alarm', (tester) async {
          await tester.verifyStepByStep(
            find.text(translate.selectAlarm, skipOffstage: false),
            genericDb,
            key: StepByStepSettings.alarmKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select checklist', (tester) async {
          await tester.verifyStepByStep(
            find.text(translate.selectChecklist, skipOffstage: false),
            genericDb,
            key: StepByStepSettings.checklistKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select note', (tester) async {
          await tester.verifyStepByStep(
            find.text(translate.selectNote, skipOffstage: false),
            genericDb,
            key: StepByStepSettings.notesKey,
            matcher: isFalse,
          );
        });

        testWidgets('deselect Select reminder', (tester) async {
          await tester.verifyStepByStep(
            find.text(translate.selectReminder, skipOffstage: false),
            genericDb,
            key: StepByStepSettings.remindersKey,
            matcher: isFalse,
          );
        });
      });
    });

    group('Defaults tab -', () {
      testWidgets('Select vibration', (tester) async {
        await tester.goToDefaultsTab();
        expect(find.byType(AddActivityDefaultSettingsTab), findsOneWidget);
        await tester.tap(find.text(translate.vibrationIfAvailable));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: DefaultsAddActivitySettings.defaultAlarmTypeKey,
          matcher: alarmVibration,
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
          key: DefaultsAddActivitySettings.defaultAlarmTypeKey,
          matcher: alarmSilentOnlyOnStart,
        );
      });

      testWidgets('Select checkable', (tester) async {
        await tester.goToDefaultsTab();
        expect(find.byType(AddActivityDefaultSettingsTab), findsOneWidget);
        await tester.tap(find.text(translate.checkable));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: DefaultsAddActivitySettings.defaultCheckableKey,
          matcher: isTrue,
        );
      });

      testWidgets('Select remove at the end of day', (tester) async {
        await tester.goToDefaultsTab();
        expect(find.byType(AddActivityDefaultSettingsTab), findsOneWidget);
        await tester.tap(find.text(translate.deleteAfter));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: DefaultsAddActivitySettings.defaultRemoveAtEndOfDayKey,
          matcher: isTrue,
        );
      });

      testWidgets('Available for - select only me', (tester) async {
        await tester.goToDefaultsTab();
        expect(find.byType(AddActivityDefaultSettingsTab), findsOneWidget);
        await tester.tap(find.text(translate.onlyMe));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: DefaultsAddActivitySettings.defaultAvailableForTypeKey,
          matcher: AvailableForType.onlyMe.index,
        );
      });

      testWidgets('Available for - select all my support persons',
          (tester) async {
        await tester.goToDefaultsTab();
        expect(find.byType(AddActivityDefaultSettingsTab), findsOneWidget);
        await tester.tap(find.text(translate.allSupportPersons));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        verifySyncGeneric(
          tester,
          genericDb,
          key: DefaultsAddActivitySettings.defaultAvailableForTypeKey,
          matcher: AvailableForType.allSupportPersons.index,
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
    required matcher,
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
    required matcher,
  }) async {
    await goToAddTab();
    await tap(find.text(Locales.language.values.first.stepByStep));
    await pumpAndSettle();
    expect(find.byType(AddActivityAddSettingsTab), findsOneWidget);
    await dragUntilVisible(
        finder, find.byType(AddActivityAddSettingsTab), const Offset(0, -100));
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
    await tap(find.byIcon(AbiliaIcons.technicalSettings));
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
    await tap(find.byIcon(AbiliaIcons.newIcon));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.settings));
    await pumpAndSettle();
  }
}