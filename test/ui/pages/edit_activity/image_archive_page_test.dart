import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../mocks.dart';
import '../../../utils/types.dart';

void main() {
  group('Image archive test', () {
    final translate = Locales.language.values.first;
    setUp(() {
      GetItInitializer()
        ..fileStorage = MockFileStorage()
        ..database = MockDatabase()
        ..flutterTts = MockFlutterTts()
        ..init();
    });

    tearDown(GetIt.I.reset);

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

    final imageInFolderName = 'Folder image';
    final imageInFolder =
        Sortable.createNew<ImageArchiveData>(data: ImageArchiveData.fromJson('''
          {"name":"$imageInFolderName","fileId":"351d5e7d-0d87-4037-9829-538a14936129","file":"/images/Basic/Basic/infolder.gif"}
          '''), groupId: folder.id);

    final mockSortableBloc = MockSortableBloc();

    final mockNavigatorObserver = MockNavigatorObserver();

    Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: [Translator.delegate],
          navigatorObservers: [mockNavigatorObserver],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          builder: (context, child) => MockAuthenticatedBlocsProvider(
            child: MultiBlocProvider(providers: [
              BlocProvider<SortableBloc>.value(
                value: mockSortableBloc,
              ),
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
          ),
          home: widget,
        );

    testWidgets('Image archive smoke test', (WidgetTester tester) async {
      when(mockSortableBloc.state)
          .thenAnswer((_) => SortablesLoaded(sortables: []));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchivePage()));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
      expect(find.byType(ArchiveImage), findsNothing);
    });

    testWidgets('Image archive with one image and no folder',
        (WidgetTester tester) async {
      when(mockSortableBloc.state)
          .thenAnswer((_) => SortablesLoaded(sortables: [image]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchivePage()));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
      expect(find.byType(ArchiveImage), findsOneWidget);
    });

    testWidgets('Image archive with one image and one folder',
        (WidgetTester tester) async {
      when(mockSortableBloc.state)
          .thenAnswer((_) => SortablesLoaded(sortables: [image, folder]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchivePage()));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
      expect(find.byType(ArchiveImage), findsOneWidget);
      expect(find.byType(LibraryFolder), findsOneWidget);
    });

    testWidgets('Selected Image is poped', (WidgetTester tester) async {
      when(mockSortableBloc.state)
          .thenAnswer((_) => SortablesLoaded(sortables: [image]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchivePage()));
      await tester.pumpAndSettle();
      expect(find.byType(ArchiveImage), findsOneWidget);
      await tester.tap(find.byType(ArchiveImage));
      await tester.pumpAndSettle();
      expect(find.byType(FullScreenImage), findsOneWidget);
      expect(find.byType(GreenButton), findsOneWidget);
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();
      final poped =
          verify(mockNavigatorObserver.didPop(captureAny, any)).captured;
      expect(poped, hasLength(1));
      final selectedImageRoute = poped.first as Route;
      final res = await selectedImageRoute.popped;
      expect(res, SelectedImage(id: fileId, path: path));
    });

    testWidgets('tts', (WidgetTester tester) async {
      when(mockSortableBloc.state)
          .thenAnswer((_) => SortablesLoaded(sortables: [image, folder]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchivePage()));
      await tester.pumpAndSettle();
      await tester.verifyTts(find.byType(LibraryFolder), exact: folderName);
      await tester.verifyTts(find.byType(ArchiveImage), exact: imageName);
      await tester.verifyTts(
        find.byType(typeOf<LibraryHeading<ImageArchiveData>>()),
        exact: translate.imageArchive,
      );
    });

    testWidgets('library heading tts', (WidgetTester tester) async {
      when(mockSortableBloc.state).thenAnswer(
          (_) => SortablesLoaded(sortables: [folder, imageInFolder]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchivePage()));
      await tester.pumpAndSettle();

      // Assert - root heading
      await tester.verifyTts(
        find.byType(typeOf<LibraryHeading<ImageArchiveData>>()),
        exact: translate.imageArchive,
      );

      expect(find.byType(LibraryFolder), findsOneWidget);
      // Act - go into folder
      await tester.tap(find.byType(LibraryFolder));
      await tester.pumpAndSettle();

      // Assert heading is folder tts
      await tester.verifyTts(
        find.byType(typeOf<LibraryHeading<ImageArchiveData>>()),
        exact: folderName,
      );
      // Act -- go into image
      await tester.tap(find.byType(ArchiveImage));
      await tester.pumpAndSettle();

      // Assert - image name tts
      await tester.verifyTts(
        find.byType(typeOf<LibraryHeading<ImageArchiveData>>()),
        exact: imageInFolderName,
      );
    });
  });
}
