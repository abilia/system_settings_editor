import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import 'package:intl/date_symbol_data_local.dart';
import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String activityNameOne = 'Basic Activity 1';
  const String activityNameTwo = 'Basic Activity 2';

  late List<Sortable> initialSortables;

  late SortableBloc mockSortableBloc;
  late MockUserFileCubit mockUserFileCubit;
  late MockMemoplannerSettingBloc mockMemoplannerSettingBloc;

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

    mockSortableBloc = MockSortableBloc();
    when(() => mockSortableBloc.state).thenAnswer(
        (invocation) => SortablesLoaded(sortables: initialSortables));

    mockUserFileCubit = MockUserFileCubit();
    when(() => mockUserFileCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    mockMemoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
            MemoplannerSettings(alarm: AlarmSettings(durationMs: 0))));

    registerFallbackValues();
    await initializeDateFormatting();

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..client = Fakes.client()
      ..database = FakeDatabase()
      ..sortableDb = MockSortableDb()
      ..battery = FakeBattery()
      ..init();
  });

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SortableBloc>(
              create: (context) => mockSortableBloc,
            ),
            BlocProvider<SortableArchiveCubit>(
              create: (context) =>
                  SortableArchiveCubit(sortableBloc: mockSortableBloc),
            ),
            BlocProvider<ClockBloc>(
              create: (context) =>
                  ClockBloc.fixed(DateTime(2011, 11, 11, 11, 11)),
            ),
            BlocProvider<SettingsCubit>(
              create: (context) => SettingsCubit(
                settingsDb: FakeSettingsDb(),
              ),
            ),
            BlocProvider<MemoplannerSettingBloc>(
              create: (context) => mockMemoplannerSettingBloc,
            ),
            BlocProvider<UserFileCubit>(
              create: (context) => mockUserFileCubit,
            ),
            BlocProvider(
              create: (context) => SortableArchiveCubit<BasicActivityData>(
                sortableBloc: BlocProvider.of<SortableBloc>(context),
              ),
            ),
            BlocProvider(
              create: (context) => SortableArchiveCubit<BasicTimerData>(
                sortableBloc: BlocProvider.of<SortableBloc>(context),
              ),
            ),
            // BlocProvider<ReorderSortablesCubit>(
            //   create: (context) => reorderSortablesCubit,
            //   ),
          ],
          child: widget,
        ),
      );

  tearDown(() {
    GetIt.I.reset();
  });

  group('Basic Templates page', () {
    testWidgets('Page shows', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const BasicTemplatesPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BasicTemplatesPage), findsOneWidget);
      expect(find.byType(CloseButton), findsOneWidget);
    });

    testWidgets('Shows 3 items in activities', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const BasicTemplatesPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PickField), findsNWidgets(3));
      expect(find.byIcon(AbiliaIcons.navigationNext), findsOneWidget);
    });

    testWidgets('Shows 1 item in timers', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const BasicTemplatesPage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
      await tester.pumpAndSettle();
      expect(find.byType(PickField), findsOneWidget);
    });

    testWidgets('Tapping folder enters', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const BasicTemplatesPage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.navigationNext));
      await tester.pumpAndSettle();
      expect(find.byType(PickField), findsNothing);
      expect(find.byType(PreviousButton), findsOneWidget);
    });

    group('Tool bar', () {
      testWidgets('Tapping item shows and hides toolbar', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
            const BasicTemplatesPage(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(activityNameOne));
        await tester.pumpAndSettle();

        expect(find.byType(SortableToolbar), findsOneWidget);

        await tester.tap(find.text(activityNameOne));
        await tester.pumpAndSettle();

        expect(find.byType(SortableToolbar), findsNothing);
      });

      testWidgets(
          'Tapping down on toolbar triggers a SortablesUpdated. Three items means it can move down twice',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
            const BasicTemplatesPage(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(activityNameOne));
        await tester.pumpAndSettle();

        expect(find.byType(SortableToolbar), findsOneWidget);

        await tester.tap(find.byKey(TestKey.checklistToolbarDownButton));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(TestKey.checklistToolbarDownButton));
        await tester.pumpAndSettle();

        // tap closes toolbar
        await tester.tap(find.byType(SortableToolbar));
        await tester.pumpAndSettle();

        expect(find.byKey(TestKey.checklistToolbarDownButton), findsNothing);

        // update should have been called twice
        verify(
          () => mockSortableBloc.add(any(that: isA<SortablesUpdated>())),
        ).called(2);
      });
    });
  });
}
