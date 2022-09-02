import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/background/notification_isolate.dart';
import 'package:seagull/db/sortable_db.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  scheduleAlarmNotificationsIsolated = noAlarmScheduler;

  TestWidgetsFlutterBinding.ensureInitialized();

  const String activityNameOne = 'Basic Activity 1';
  const String activityNameTwo = 'Basic Activity 2';
  const String timerTitle = 'Basic Timer';

  late List<Sortable> initialSortables;
  late SortableDb mockSortableDb;
  setUpAll(() {
    tz.initializeTimeZones();
    setupPermissions();
  });

  final basicActivitySortable = Sortable.createNew<BasicActivityDataItem>(
    data: BasicActivityDataItem.createNew(title: activityNameOne),
  );

  setUp(() async {
    initialSortables = [
      basicActivitySortable,
      Sortable.createNew<BasicActivityDataItem>(
        data: BasicActivityDataItem.createNew(title: activityNameTwo),
      ),
      Sortable.createNew<BasicActivityDataFolder>(
        isGroup: true,
        data: BasicActivityDataFolder.createNew(name: 'Folder'),
      ),
      Sortable.createNew<BasicTimerDataItem>(
        data: BasicTimerDataItem.fromJson(
            '{"duration":60000,"title":"$timerTitle"}'),
      ),
    ];

    mockSortableDb = MockSortableDb();

    when(() => mockSortableDb.getAllNonDeleted()).thenAnswer(
      (invocation) => Future.value(initialSortables),
    );

    when(() => mockSortableDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    when(() => mockSortableDb.getAllDirty())
        .thenAnswer((_) => Future.value(<DbModel<Sortable>>[]));

    registerFallbackValues();

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..client = Fakes.client()
      ..database = FakeDatabase()
      ..sortableDb = mockSortableDb
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('Basic Templates page', () {
    testWidgets('Page shows', (tester) async {
      await tester.goToTemplates();
      expect(find.byType(BasicTemplatesPage), findsOneWidget);
      expect(find.byType(CloseButton), findsOneWidget);
    });

    testWidgets('Shows 3 items in activities', (tester) async {
      await tester.goToTemplates();
      expect(find.byType(ListDataItem), findsNWidgets(2));
      expect(find.byType(PickField), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.navigationNext), findsOneWidget);
    });

    testWidgets('Shows 1 item in timers', (tester) async {
      await tester.goToTemplates();
      await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
      await tester.pumpAndSettle();
      expect(find.byType(ListDataItem), findsOneWidget);
    });

    testWidgets('Tapping folder enters, shows LibraryHeading', (tester) async {
      await tester.goToTemplates();
      await tester.tap(find.byIcon(AbiliaIcons.navigationNext));
      await tester.pumpAndSettle();
      expect(find.byType(PickField), findsNothing);
      expect(find.byType(LibraryHeading<BasicActivityData>), findsOneWidget);
    });

    group('Tool bar', () {
      testWidgets(
          'Tapping item shows and hides toolbar, never shows LibraryHeading',
          (tester) async {
        await tester.goToTemplates();
        await tester.tap(find.text(activityNameOne));
        await tester.pumpAndSettle();

        expect(find.byType(SortableToolbar), findsOneWidget);
        expect(find.byType(LibraryHeading), findsNothing);

        await tester.tap(find.text(activityNameOne));
        await tester.pumpAndSettle();

        expect(find.byType(SortableToolbar), findsNothing);
      });

      testWidgets('Tapping down moves activity down and changes sort order',
          (tester) async {
        await tester.goToTemplates();
        await tester.tap(find.text(activityNameOne));
        await tester.pumpAndSettle();

        expect(find.byType(SortableToolbar), findsOneWidget);

        await tester.tap(find.byIcon(AbiliaIcons.cursorDown));
        await tester.pumpAndSettle();

        final capturedSortable =
            verify(() => mockSortableDb.insertAndAddDirty(captureAny()))
                .captured;
        for (var element in (capturedSortable.last as List)) {
          if (element.data.title == activityNameOne) {
            expect(element.sortOrder, '1');
          } else if (element.data.title == activityNameTwo) {
            expect(element.sortOrder, '0');
          }
        }
      });

      testWidgets('Delete sortable', (tester) async {
        await tester.goToTemplates();
        await tester.tap(find.text(activityNameOne));
        await tester.pumpAndSettle();

        expect(find.byType(SortableToolbar), findsOneWidget);

        await tester.tap(find.byIcon(AbiliaIcons.deleteAllClear));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(YesButton));
        await tester.pumpAndSettle();

        final capturedSortable =
            verify(() => mockSortableDb.insertAndAddDirty(captureAny()))
                .captured
                .whereType<List<Sortable>>()
                .expand((l) => l);
        expect(capturedSortable, hasLength(3));
        expect(capturedSortable.last.deleted, isTrue);
      });

      testWidgets('Edit sortable activity', (tester) async {
        await tester.goToTemplates();
        await tester.tap(find.text(activityNameOne));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.edit));
        await tester.pumpAndSettle();

        expect(find.byType(EditActivityPage), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.repeat), findsNothing);
        expect(find.byType(DatePicker), findsNothing);

        // Change title
        const newTitle = 'newActivtyTitle';
        await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField),
          newTitle,
        );
        // Change alarm
        await tester.tap(find.byIcon(AbiliaIcons.attention));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.selectAlarm));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ObjectKey(AlarmType.silent)));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        // No speech on start or speech on end
        expect(find.byType(RecordSoundWidget), findsNothing);

        // add reminder
        await tester.tap(find.byType(ReminderSwitch));
        await tester.pumpAndSettle();

        // add info item note
        const noteText = 'note Text';
        await tester.tap(find.byIcon(AbiliaIcons.attachment));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ChangeInfoItemPicker));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NoteBlock));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), noteText);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();

        // SAVE
        await tester.tap(find.byType(SaveButton));
        await tester.pumpAndSettle();

        expect(find.byType(BasicTemplatesPage), findsOneWidget);

        final capturedSortable =
            verify(() => mockSortableDb.insertAndAddDirty(captureAny()))
                .captured
                .whereType<List<Sortable>>()
                .expand((l) => l);
        final updated = capturedSortable.last;

        expect(updated.id, basicActivitySortable.id);
        final basicActivity = updated.data as BasicActivityDataItem;
        // Expect new title
        expect(basicActivity.activityTitle, newTitle);
        expect(basicActivity.name, newTitle);
        // Expect new alarm
        expect(basicActivity.alarmType, alarmSilentOnlyOnStart);
        // Expect new reminders
        expect(basicActivity.reminders,
            '${const Duration(minutes: 15).inMilliseconds}');
        // Expect note
        expect(
          basicActivity.info,
          '{"info-item":[{"type":"note","data":{"text":"note Text"}}]}',
        );
      });

      testWidgets('Can edit timer template', (tester) async {
        const newTitle = 'new title';

        await tester.goToTemplates();
        await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
        await tester.pumpAndSettle();
        await tester.tap(find.text(timerTitle));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.edit));
        await tester.pumpAndSettle();
        expect(find.byType(EditBasicTimerPage), findsOneWidget);

        await tester.ourEnterText(
          find.byType(AbiliaTextInput),
          newTitle,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(AbiliaIcons.clock));
        await tester.pumpAndSettle();
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(SaveButton));
        await tester.pumpAndSettle();
        expect(find.byType(EditTimerPage), findsNothing);
        final captured =
            verify(() => mockSortableDb.insertAndAddDirty(captureAny()))
                .captured
                .last;

        final sortable = (captured as List).single as Sortable<SortableData>;

        final dataItem = sortable.data as BasicTimerDataItem;
        expect(dataItem.basicTimerTitle, newTitle);
        expect(dataItem.duration, const Duration(minutes: 19).inMilliseconds);
      });
    });

    group('Create Basic templates', () {
      testWidgets('Can create sortable activity', (tester) async {
        const title = 'a brand new title';
        await tester.goToTemplates();
        await tester.tap(find.byType(AddTemplateButton));
        await tester.pumpAndSettle();
        expect(find.byType(EditActivityPage), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.repeat), findsNothing);
        expect(find.byType(DatePicker), findsNothing);
        expect(find.byType(CancelButton), findsOneWidget);
        expect(find.byType(PreviousButton), findsNothing);

        await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField),
          title,
        );
        await tester.tap(find.byType(NextWizardStepButton));
        await tester.pumpAndSettle();
        expect(find.byType(EditActivityPage), findsNothing);
        final captured =
            verify(() => mockSortableDb.insertAndAddDirty(captureAny()))
                .captured
                .last;

        final sortable =
            (captured as List).single as Sortable<BasicActivityDataItem>;
        expect(sortable.data.activityTitle, title);
        expect(sortable.data.name, title);
      });

      testWidgets('Can create basic timer', (tester) async {
        const enteredTitle = 'a basic timer';
        final duration = const Duration(minutes: 5).inMilliseconds;
        await tester.goToTemplates();
        await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(AddTemplateButton));
        await tester.pumpAndSettle();
        expect(find.byType(EditBasicTimerPage), findsOneWidget);
        expect(find.byType(SaveButton), findsOneWidget);
        expect(find.byType(CancelButton), findsOneWidget);
        expect(find.byType(PreviousButton), findsNothing);

        await tester.ourEnterText(
          find.byType(AbiliaTextInput),
          enteredTitle,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(AbiliaIcons.clock));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(SaveButton));
        await tester.pumpAndSettle();
        expect(find.byType(EditTimerPage), findsNothing);
        final captured =
            verify(() => mockSortableDb.insertAndAddDirty(captureAny()))
                .captured
                .last;

        final sortable = (captured as List).single as Sortable<SortableData>;

        final dataItem = sortable.data as BasicTimerDataItem;
        expect(dataItem.basicTimerTitle, enteredTitle);
        expect(dataItem.duration, duration);
      });
    });
  });
}

extension on WidgetTester {
  Future<void> goToTemplates() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(BasicTemplatesButton));
    await pumpAndSettle();
  }
}
