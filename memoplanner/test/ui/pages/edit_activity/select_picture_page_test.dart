import 'package:flutter_test/flutter_test.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  group('SelectPicturePage test', () {
    late MockSortableBloc mockSortableBloc;
    late MemoplannerSettingsBloc mockMemoplannerSettingsBloc;

    setUpAll(() async {
      await Lokalise.initMock();
      registerFallbackValues();
    });

    setUp(() async {
      mockSortableBloc = MockSortableBloc();
      when(() => mockSortableBloc.stream)
          .thenAnswer((_) => const Stream.empty());
      mockMemoplannerSettingsBloc = MockMemoplannerSettingBloc();
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(template: false),
            ),
          ),
        ),
      );

      when(() => mockMemoplannerSettingsBloc.stream)
          .thenAnswer((_) => const Stream.empty());
    });

    Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
          localizationsDelegates: const [Lt.delegate],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          builder: (context, child) => FakeAuthenticatedBlocsProvider(
            child: MultiBlocProvider(providers: [
              BlocProvider<MemoplannerSettingsBloc>.value(
                value: mockMemoplannerSettingsBloc,
              ),
              BlocProvider<SortableBloc>.value(
                value: mockSortableBloc,
              ),
              BlocProvider<SpeechSettingsCubit>(
                create: (context) => FakeSpeechSettingsCubit(),
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
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            photoMenu: PhotoMenuSettings(
              displayMyPhotos: false,
            ),
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
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            photoMenu: PhotoMenuSettings(
              displayCamera: false,
            ),
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
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            photoMenu: PhotoMenuSettings(
              displayLocalImages: false,
            ),
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
