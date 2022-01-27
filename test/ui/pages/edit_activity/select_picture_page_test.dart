import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  group('SelectPicturePage test', () {
    late MockSortableBloc mockSortableBloc;
    late MemoplannerSettingBloc mockMemoplannerSettingsBloc;

    setUpAll(() {
      registerFallbackValues();
    });

    setUp(() async {
      mockSortableBloc = MockSortableBloc();
      when(() => mockSortableBloc.stream)
          .thenAnswer((_) => const Stream.empty());
      mockMemoplannerSettingsBloc = MockMemoplannerSettingBloc();
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
          const MemoplannerSettingsLoaded(
              MemoplannerSettings(advancedActivityTemplate: false)));
      when(() => mockMemoplannerSettingsBloc.stream)
          .thenAnswer((_) => const Stream.empty());
    });

    Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: const [Translator.delegate],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          builder: (context, child) => FakeAuthenticatedBlocsProvider(
            child: MultiBlocProvider(providers: [
              BlocProvider<MemoplannerSettingBloc>.value(
                value: mockMemoplannerSettingsBloc,
              ),
              BlocProvider<SortableBloc>.value(
                value: mockSortableBloc,
              ),
              BlocProvider<SettingsCubit>(
                create: (context) => SettingsCubit(
                  settingsDb: FakeSettingsDb(),
                ),
              ),
            ], child: child!),
          ),
          home: widget,
        );

    testWidgets('SelectPicturePage smoke test', (WidgetTester tester) async {
      when(() => mockSortableBloc.state)
          .thenAnswer((_) => const SortablesLoaded(sortables: []));
      await tester.pumpWidget(wrapWithMaterialApp(
          const SelectPicturePage(selectedImage: AbiliaFile.empty)));
      await tester.pumpAndSettle();
      expect(find.byType(SelectPicturePage), findsOneWidget);
      expect(find.byKey(TestKey.myPhotosButton), findsOneWidget);
      expect(find.byKey(TestKey.cameraPickField), findsOneWidget);
    });

    testWidgets('no myphotos settings shows no myphotos pickfield',
        (WidgetTester tester) async {
      when(() => mockSortableBloc.state)
          .thenAnswer((_) => const SortablesLoaded(sortables: []));
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            imageMenuDisplayMyPhotosItem: false,
          ),
        ),
      );
      await tester.pumpWidget(wrapWithMaterialApp(
          const SelectPicturePage(selectedImage: AbiliaFile.empty)));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.myPhotosButton), findsNothing);
    });

    testWidgets('no camera settings shows no camera pickfield',
        (WidgetTester tester) async {
      when(() => mockSortableBloc.state)
          .thenAnswer((_) => const SortablesLoaded(sortables: []));
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            imageMenuDisplayCameraItem: false,
          ),
        ),
      );
      await tester.pumpWidget(wrapWithMaterialApp(
          const SelectPicturePage(selectedImage: AbiliaFile.empty)));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.cameraPickField), findsNothing);
    });

    testWidgets('no local images settings shows no local images pickfield',
        (WidgetTester tester) async {
      when(() => mockSortableBloc.state)
          .thenAnswer((_) => const SortablesLoaded(sortables: []));
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            imageMenuDisplayPhotoItem: false,
          ),
        ),
      );
      await tester.pumpWidget(wrapWithMaterialApp(
          const SelectPicturePage(selectedImage: AbiliaFile.empty)));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.localImagesPickField), findsNothing);
    });
  });
}
