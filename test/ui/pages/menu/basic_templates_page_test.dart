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

  setUp(() async {
    setupPermissions();
    final mockSortableDb = MockSortableDb();
    when(() => mockSortableDb.getAllNonDeleted()).thenAnswer(
      (invocation) => Future.value(
        <Sortable<SortableData>>[
          Sortable.createNew<BasicActivityDataItem>(
            data: BasicActivityDataItem.createNew(title: 'Basic Activity 1'),
          ),
          Sortable.createNew<BasicActivityDataItem>(
            data: BasicActivityDataItem.createNew(title: 'Basic Activity 2'),
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

    testWidgets('Shows 2 items in activities', (tester) async {
      await tester.goToTemplates();
      expect(find.byType(PickField), findsNWidgets(2));
    });

    testWidgets('Shows 1 item in timers', (tester) async {
      await tester.goToTemplates();
      await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
      await tester.pumpAndSettle();
      expect(find.byType(PickField), findsOneWidget);
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
