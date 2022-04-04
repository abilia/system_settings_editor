import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/background/notification_isolate.dart';
import 'package:seagull/db/sortable_db.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  scheduleAlarmNotificationsIsolated = noAlarmScheduler;

  TestWidgetsFlutterBinding.ensureInitialized();

  const String activityNameOne = 'Basic Activity 1';
  const String activityNameTwo = 'Basic Activity 2';

  late List<Sortable> initialSortables;
  late SortableDb mockSortableDb;

  setUp(() async {
    setupPermissions();

    initialSortables = [
      Sortable.createNew<BasicActivityDataItem>(
        data: BasicActivityDataItem.createNew(title: activityNameOne),
      ),
      Sortable.createNew<BasicActivityDataItem>(
        data: BasicActivityDataItem.createNew(title: activityNameTwo),
      ),
      Sortable.createNew<BasicActivityDataItem>(
        isGroup: true,
        data: BasicActivityDataItem.createNew(title: 'Folder'),
      ),
      Sortable.createNew<BasicTimerDataItem>(
        data: BasicTimerDataItem.fromJson(
            '{"duration":60000,"title":"Basic Timer"}'),
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
      expect(find.byType(PickField), findsNWidgets(3));
      expect(find.byIcon(AbiliaIcons.navigationNext), findsOneWidget);
    });

    testWidgets('Shows 1 item in timers', (tester) async {
      await tester.goToTemplates();
      await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
      await tester.pumpAndSettle();
      expect(find.byType(PickField), findsOneWidget);
    });

    testWidgets('Tapping folder enters', (tester) async {
      await tester.goToTemplates();
      await tester.tap(find.byIcon(AbiliaIcons.navigationNext));
      await tester.pumpAndSettle();
      expect(find.byType(PickField), findsNothing);
      expect(find.byType(PreviousButton), findsOneWidget);
    });

    group('Tool bar', () {
      testWidgets('Tapping item shows and hides toolbar', (tester) async {
        await tester.goToTemplates();
        await tester.tap(find.text(activityNameOne));
        await tester.pumpAndSettle();

        expect(find.byType(SortableToolbar), findsOneWidget);

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

        await tester.tap(find.byKey(TestKey.checklistToolbarDownButton));
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

        await tester.tap(find.byKey(TestKey.checklistToolbarDeleteQButton));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(YesButton));
        await tester.pumpAndSettle();

        final capturedSortable =
            verify(() => mockSortableDb.insertAndAddDirty(captureAny()))
                .captured;

        int deleted = 0;
        for (var element in (capturedSortable.last as List)) {
          if (element.deleted) {
            deleted++;
          }
        }
        expect(deleted, 1);
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
