import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:collection/collection.dart';

import '../../../mocks.dart';

void main() {
  group('Image archive test', () {
    setUp(() {
      GetItInitializer()
        ..fileStorage = MockFileStorage()
        ..database = MockDatabase()
        ..flutterTts = MockFlutterTts()
        ..init();
    });
    final fileId = '351d5e7d-0d87-4037-9829-538a14936128',
        path = '/images/Basic/Basic/bingo.gif';

    final imageName = 'bingo';
    final imageData = ImageArchiveData.fromJson('''
          {"name":"$imageName","fileId":"$fileId","file":"$path"}
          ''');
    final image = Sortable.createNew<ImageArchiveData>(data: imageData);

    final folderName = 'Basic';
    final folderData = ImageArchiveData.fromJson('''
          {"name":"$folderName","fileId":"19da3060-be12-42f9-922e-7e1635293126","icon":"/images/Basic/Basic.png"}
          ''');
    final folder =
        Sortable.createNew<ImageArchiveData>(data: folderData, isGroup: true);

    final imageArchiveBlocMock = MockImageArchiveBloc();

    final mockNavigatorObserver = MockNavigatorObserver();

    Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: [Translator.delegate],
          navigatorObservers: [mockNavigatorObserver],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          builder: (context, child) => MultiBlocProvider(providers: [
            BlocProvider<AuthenticationBloc>(
                create: (context) => MockAuthenticationBloc()),
            BlocProvider<SortableArchiveBloc<ImageArchiveData>>(
                create: (context) => imageArchiveBlocMock),
            BlocProvider<UserFileBloc>(
              create: (context) => UserFileBloc(
                fileStorage: MockFileStorage(),
                pushBloc: MockPushBloc(),
                syncBloc: MockSyncBloc(),
                userFileRepository: MockUserFileRepository(),
              ),
            ),
            BlocProvider<SettingsBloc>(
              create: (context) => SettingsBloc(
                settingsDb: MockSettingsDb(),
              ),
            ),
          ], child: child),
          home: widget,
        );

    testWidgets('Image archive smoke test', (WidgetTester tester) async {
      when(imageArchiveBlocMock.state)
          .thenAnswer((_) => stateFromSortables([]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchive()));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchive), findsOneWidget);
      expect(find.byType(ArchiveImage), findsNothing);
    });

    testWidgets('Image archive with one image and no folder',
        (WidgetTester tester) async {
      when(imageArchiveBlocMock.state)
          .thenAnswer((_) => stateFromSortables([image]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchive()));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchive), findsOneWidget);
      expect(find.byType(ArchiveImage), findsOneWidget);
    });

    testWidgets('Image archive with one image and one folder',
        (WidgetTester tester) async {
      when(imageArchiveBlocMock.state)
          .thenAnswer((_) => stateFromSortables([image, folder]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchive()));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchive), findsOneWidget);
      expect(find.byType(ArchiveImage), findsOneWidget);
      expect(find.byType(LibraryFolder), findsOneWidget);
    });

    testWidgets('Selected Image is poped', (WidgetTester tester) async {
      when(imageArchiveBlocMock.state)
          .thenAnswer((_) => stateFromSortables([image]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchive()));
      await tester.pumpAndSettle();
      expect(find.byType(ArchiveImage), findsOneWidget);
      await tester.tap(find.byType(ArchiveImage));
      await tester.pumpAndSettle();
      expect(find.byType(FullScreenImage), findsOneWidget);
      expect(find.byKey(TestKey.okDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.okDialog));
      await tester.pumpAndSettle();
      final poped =
          verify(mockNavigatorObserver.didPop(captureAny, any)).captured;
      expect(poped, hasLength(1));
      final route = poped.first;
      expect(route, isA<Route<SelectedImage>>());
      final selectedImageRoute = route as Route<SelectedImage>;
      final res = await selectedImageRoute.popped;
      expect(res, SelectedImage(id: fileId, path: path));
    });

    testWidgets('tts', (WidgetTester tester) async {
      when(imageArchiveBlocMock.state)
          .thenAnswer((_) => stateFromSortables([image, folder]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchive()));
      await tester.pumpAndSettle();
      await tester.verifyTts(find.byType(LibraryFolder), exact: folderName);
      await tester.verifyTts(find.byType(ArchiveImage), exact: imageName);
    });
  });
}

SortableArchiveState stateFromSortables(
  List<Sortable<ImageArchiveData>> sortables, {
  String folderId,
}) {
  final allByFolder =
      groupBy<Sortable<ImageArchiveData>, String>(sortables, (s) => s.groupId);
  final allById = {for (var s in sortables) s.id: s};
  return SortableArchiveState<ImageArchiveData>(allByFolder, allById, folderId);
}
