import 'package:flutter_test/flutter_test.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:repository_base/models/data_models.dart';

import 'package:sortables/db/sortable_db.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  scheduleNotificationsIsolated = noAlarmScheduler;

  TestWidgetsFlutterBinding.ensureInitialized();

  const String activityNameOne = 'Basic Activity 1';
  const String activityNameTwo = 'Basic Activity 2';
  const String timerTitle = 'Basic Timer';
  late final Lt translate;

  late List<Sortable> initialSortables;
  late SortableDb mockSortableDb;
  setUpAll(() async {
    await Lokalise.initMock();
    translate = await Lt.load(Lt.supportedLocales.first);
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
      ..client = fakeClient()
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
      expect(find.byType(TemplatesPage), findsOneWidget);
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

      testWidgets('SGC-1639 - Switching tabs resets selected item',
          (tester) async {
        await tester.goToTemplates();
        await tester.tap(find.text(activityNameOne));
        await tester.pumpAndSettle();

        expect(find.byType(SortableToolbar), findsOneWidget);

        await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.basicActivity));
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
        expect(capturedSortable, hasLength(3)); // 1 and 2 are fixed folders
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
        await tester.tap(find.text((15.minutes().toDurationString(translate))));
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

        expect(find.byType(TemplatesPage), findsOneWidget);

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

      testWidgets(
          'Edit an activity and clicking cancel triggers discard warning dialog',
          (tester) async {
        await tester.goToTemplates();
        await tester.tap(find.text(activityNameOne));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.edit));
        await tester.pumpAndSettle();

        // Change title
        const newTitle = 'newActivtyTitle';
        await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField),
          newTitle,
        );

        await tester.tap(find.byType(CancelButton));
        await tester.pumpAndSettle();
        expect(find.byType(DiscardWarningDialog), findsOneWidget);
      });

      testWidgets(
          'Edit a timer and clicking cancel triggers discard warning dialog',
          (tester) async {
        await tester.goToTemplates();
        await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
        await tester.pumpAndSettle();
        await tester.tap(find.text(timerTitle));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.edit));
        await tester.pumpAndSettle();
        expect(find.byType(EditBasicTimerPage), findsOneWidget);

        // Change title
        await tester.ourEnterText(
          find.byType(AbiliaTextInput),
          'new title',
        );

        await tester.tap(find.byType(CancelButton));
        await tester.pumpAndSettle();
        expect(find.byType(DiscardWarningDialog), findsOneWidget);
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
        const jankDuration = Duration(seconds: 1);
        const enteredTitle = 'a basic timer';
        final duration = const Duration(minutes: 5).inMilliseconds;
        await tester.goToTemplates();
        await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(AddTemplateButton));
        await tester.pumpTwice();
        expect(find.byType(EditBasicTimerPage), findsOneWidget);
        expect(find.byType(SaveButton), findsOneWidget);
        expect(find.byType(CancelButton), findsOneWidget);
        expect(find.byType(PreviousButton), findsNothing);

        await tester.tap(find.byType(AbiliaTextInput), warnIfMissed: false);
        await tester.pump();
        await tester.enterText(find.byKey(TestKey.input), enteredTitle);
        await tester.pumpTwice(duration: jankDuration);
        await tester.tap(find.byKey(TestKey.inputOk));
        await tester.pump();
        await tester.tap(find.byIcon(AbiliaIcons.clock));
        await tester.pumpTwice();
        await tester.tap(find.text('5'));
        await tester.pumpTwice(duration: jankDuration);
        await tester.tap(find.byType(OkButton));
        await tester.pumpTwice(duration: jankDuration);
        await tester.tap(find.byType(SaveButton));
        await tester.pumpTwice(duration: jankDuration);

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

      testWidgets(
          'Create an activity and clicking cancel triggers discard warning dialog',
          (tester) async {
        const title = 'a brand new title';
        await tester.goToTemplates();
        await tester.tap(find.byType(AddTemplateButton));
        await tester.pumpAndSettle();
        await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField),
          title,
        );
        await tester.tap(find.byType(CancelButton));
        await tester.pumpAndSettle();
        expect(find.byType(DiscardWarningDialog), findsOneWidget);
      });

      testWidgets(
          'Create a timer and clicking cancel triggers discard warning dialog',
          (tester) async {
        const jankDuration = Duration(seconds: 1);
        await tester.goToTemplates();
        await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AddTemplateButton));
        await tester.pumpTwice();
        await tester.tap(find.byType(AbiliaTextInput), warnIfMissed: false);
        await tester.pump();
        await tester.enterText(find.byKey(TestKey.input), 'a basic timer');
        await tester.pumpTwice(duration: jankDuration);
        await tester.tap(find.byKey(TestKey.inputOk));
        await tester.pumpTwice(duration: jankDuration);
        await tester.tap(find.byType(CancelButton));
        await tester.pump();
        expect(find.byType(DiscardWarningDialog), findsOneWidget);
      });
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future<void> pumpTwice({Duration duration = Duration.zero}) async {
    await pump();
    await pump(duration);
  }

  Future<void> goToTemplates() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(BasicTemplatesButton));
    await pumpAndSettle();
  }
}
