import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String activityNameOne = 'Basic Activity 1';
  const String activityNameTwo = 'Basic Activity 2';

  setUp(() async {
    setupPermissions();
    final mockSortableDb = MockSortableDb();
    when(() => mockSortableDb.getAllNonDeleted()).thenAnswer(
      (invocation) => Future.value(
        <Sortable<SortableData>>[
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
        ],
      ),
    );

    when(() => mockSortableDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    when(() => mockSortableDb.getAllDirty())
        .thenAnswer((_) => Future.value(<DbModel<Sortable>>[]));

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
