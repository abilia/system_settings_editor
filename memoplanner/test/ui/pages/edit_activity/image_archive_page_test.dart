import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/navigation_observer.dart';
import '../../../test_helpers/register_fallback_values.dart';
import '../../../test_helpers/tts.dart';

void main() {
  final translate = Locales.language.values.first;
  late MockSortableBloc mockSortableBloc;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    mockSortableBloc = MockSortableBloc();
    when(() => mockSortableBloc.stream).thenAnswer((_) => const Stream.empty());
    setupFakeTts();
    GetItInitializer()
      ..fileStorage = FakeFileStorage()
      ..database = FakeDatabase()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..init();
  });

  tearDown(GetIt.I.reset);

  const fileId = '351d5e7d-0d87-4037-9829-538a14936128',
      path = '/images/Basic/Basic/bingo.gif';

  const imageName = 'bingo';
  final imageData = ImageArchiveData.fromJson('''
          {"name":"$imageName","fileId":"$fileId","file":"$path"}
          ''');
  final image = Sortable.createNew<ImageArchiveData>(data: imageData);

  const folderName = 'Basic';
  final folderData = ImageArchiveData.fromJson('''
          {"name":"$folderName","fileId":"19da3060-be12-42f9-922e-7e1635293126","icon":"/images/Basic/Basic.png"}
          ''');
  final folder =
      Sortable.createNew<ImageArchiveData>(data: folderData, isGroup: true);

  const imageInFolderName = 'Folder image';
  final imageInFolder =
      Sortable.createNew<ImageArchiveData>(data: ImageArchiveData.fromJson('''
          {"name":"$imageInFolderName","fileId":"351d5e7d-0d87-4037-9829-538a14936129","file":"/images/Basic/Basic/infolder.gif"}
          '''), groupId: folder.id);

  final folderData2 = ImageArchiveData.fromJson('''
          {"name":"folder2","fileId":"20da3060-be12-42f9-922e-7e1632993199","icon":"/images/Basic/Basic.png"}
          ''');
  final folderInsideFolder = Sortable.createNew<ImageArchiveData>(
      data: folderData2, isGroup: true, groupId: folder.id);

  final navObserver = NavObserver();

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        navigatorObservers: [navObserver],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        builder: (context, child) => FakeAuthenticatedBlocsProvider(
          child: MultiBlocProvider(providers: [
            BlocProvider<SortableBloc>.value(
              value: mockSortableBloc,
            ),
            BlocProvider<UserFileCubit>(
              create: (context) => UserFileCubit(
                fileStorage: FakeFileStorage(),
                syncBloc: FakeSyncBloc(),
                userFileRepository: FakeUserFileRepository(),
              ),
            ),
            BlocProvider<SpeechSettingsCubit>(
              create: (context) => FakeSpeechSettingsCubit(),
            ),
          ], child: child!),
        ),
        home: widget,
      );

  testWidgets('Image archive smoke test', (WidgetTester tester) async {
    await mockNetworkImages(() async {
      when(() => mockSortableBloc.state)
          .thenAnswer((_) => const SortablesLoaded(sortables: []));
      await tester.pumpWidget(wrapWithMaterialApp(const ImageArchivePage()));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
      expect(find.byType(ArchiveImage), findsNothing);
    });
  });

  testWidgets('Image archive with one image and no folder',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      when(() => mockSortableBloc.state)
          .thenAnswer((_) => SortablesLoaded(sortables: [image]));
      await tester.pumpWidget(wrapWithMaterialApp(const ImageArchivePage()));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
      expect(find.byType(ArchiveImage), findsOneWidget);
    });
  });

  testWidgets('Image archive with one image and one folder',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      when(() => mockSortableBloc.state)
          .thenAnswer((_) => SortablesLoaded(sortables: [image, folder]));
      await tester.pumpWidget(wrapWithMaterialApp(const ImageArchivePage()));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
      expect(find.byType(ArchiveImage), findsOneWidget);
      expect(find.byType(LibraryFolder), findsOneWidget);
    });
  });

  testWidgets('Selected Image is poped', (WidgetTester tester) async {
    await mockNetworkImages(() async {
      when(() => mockSortableBloc.state)
          .thenAnswer((_) => SortablesLoaded(sortables: [image]));
      await tester.pumpWidget(wrapWithMaterialApp(const ImageArchivePage()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ArchiveImage));
      await tester.pumpAndSettle();
      expect(find.byType(FullScreenImage), findsOneWidget);
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();
      final poped = navObserver.routesPoped;
      expect(poped, hasLength(1));
      final res = await poped.first.popped;
      expect(res, AbiliaFile.from(id: fileId, path: path));
    });
  });

  testWidgets('tts', (WidgetTester tester) async {
    await mockNetworkImages(() async {
      when(() => mockSortableBloc.state)
          .thenAnswer((_) => SortablesLoaded(sortables: [image, folder]));
      await tester.pumpWidget(wrapWithMaterialApp(const ImageArchivePage()));
      await tester.pumpAndSettle();
      await tester.verifyTts(find.byType(LibraryFolder), exact: folderName);
      await tester.verifyTts(find.byType(ArchiveImage), exact: imageName);
      await tester.verifyTts(
        find.byType(LibraryHeading<ImageArchiveData>),
        exact: translate.imageArchive,
      );
    });
  });

  testWidgets('library heading tts', (WidgetTester tester) async {
    const folderName = 'Basic 2';
    final folderData = ImageArchiveData.fromJson('''
          {"name":"$folderName","fileId":"7e1635293126","icon":"/images/Basic/Basic.png"}
          ''');
    final folder =
        Sortable.createNew<ImageArchiveData>(data: folderData, isGroup: true);

    const imageInFolderName = 'Folder image 2';
    final imageInFolder =
        Sortable.createNew<ImageArchiveData>(data: ImageArchiveData.fromJson('''
          {"name":"$imageInFolderName","fileId":"351d5e7d","file":"/images/Basic/Basic/infolder.gif"}
          '''), groupId: folder.id);
    await mockNetworkImages(() async {
      when(() => mockSortableBloc.state).thenAnswer(
          (_) => SortablesLoaded(sortables: [folder, imageInFolder]));
      await tester.pumpWidget(wrapWithMaterialApp(const ImageArchivePage()));
      await tester.pumpAndSettle();

      // Assert - root heading
      await tester.verifyTts(
        find.byType(LibraryHeading<ImageArchiveData>),
        exact: translate.imageArchive,
      );

      expect(find.byType(LibraryFolder), findsOneWidget);
      // Act - go into folder
      await tester.tap(find.byType(LibraryFolder));
      await tester.pumpAndSettle();

      // Assert heading is folder tts
      await tester.verifyTts(
        find.byType(LibraryHeading<ImageArchiveData>),
        exact: folderName,
      );
      // Act -- go into image
      await tester.tap(find.byType(ArchiveImage));
      await tester.pumpAndSettle();

      // Assert - image name tts
      await tester.verifyTts(
        find.byType(LibraryHeading<ImageArchiveData>),
        exact: imageInFolderName,
      );
    });
  });

  testWidgets('Image archive heading', (WidgetTester tester) async {
    await mockNetworkImages(() async {
      const folderName = 'Folder Name';

      when(() => mockSortableBloc.state).thenAnswer(
        (_) => SortablesLoaded(
          sortables: [
            Sortable.createNew<ImageArchiveData>(
              isGroup: true,
              data: const ImageArchiveData(name: folderName),
            ),
          ],
        ),
      );

      await tester.pumpWidget(wrapWithMaterialApp(const ImageArchivePage()));
      await tester.pumpAndSettle();

      // Act -- go to folder
      await tester.tap(find.text(folderName));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
            of: find.byType(LibraryHeading<ImageArchiveData>),
            matching: find.text(folderName)),
        findsOneWidget,
      );
    });
  });

  testWidgets('MyPhotos folder hidden in ImageArchivePage',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      const myPhotosFolderName = 'MyPhotos';
      when(() => mockSortableBloc.state).thenAnswer(
        (_) => SortablesLoaded(
          sortables: [
            Sortable.createNew<ImageArchiveData>(
              isGroup: true,
              data: const ImageArchiveData(
                  name: myPhotosFolderName, myPhotos: true),
            ),
          ],
        ),
      );

      await tester.pumpWidget(wrapWithMaterialApp(const ImageArchivePage()));
      await tester.pumpAndSettle();
      expect(find.byType(LibraryFolder), findsNothing);
    });
  });

  testWidgets(
      'Image archive with one image inside folder, folder is initialFolder',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      when(() => mockSortableBloc.state).thenAnswer(
          (_) => SortablesLoaded(sortables: [folder, imageInFolder]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchivePage(
        initialFolder: folder.id,
      )));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
      expect(find.byType(ArchiveImage), findsOneWidget);
      expect(find.byType(LibraryFolder), findsNothing);
    });
  });

  testWidgets('Image archive with custom header', (WidgetTester tester) async {
    await mockNetworkImages(() async {
      const testHeader = 'MyTestHeader';

      final imageInFolder = Sortable.createNew<ImageArchiveData>(
          data: const ImageArchiveData(
        name: 'name3',
        fileId: 'fildid3',
        file: '/images/Basic/Basic/infolder3.gif',
      ));
      when(() => mockSortableBloc.state).thenAnswer(
          (_) => SortablesLoaded(sortables: [folder, imageInFolder]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchivePage(
        initialFolder: folder.id,
        header: testHeader,
      )));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
      expect(find.text(testHeader), findsOneWidget);
    });
  });

  testWidgets('mobilePicture gets correct folder title',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      when(() => mockSortableBloc.state).thenAnswer(
        (_) => SortablesLoaded(
          sortables: [
            Sortable.createNew<ImageArchiveData>(
              isGroup: true,
              data: const ImageArchiveData(
                name: "some name we don't care about",
                upload: true,
              ),
            ),
          ],
        ),
      );
      await tester.pumpWidget(wrapWithMaterialApp(const ImageArchivePage()));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
            of: find.byType(LibraryFolder),
            matching: find.text(translate.mobilePictures)),
        findsOneWidget,
      );
    });
  });

  testWidgets(
      'Image archive with one folder inside initial folder, can go into folder',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      when(() => mockSortableBloc.state).thenAnswer(
          (_) => SortablesLoaded(sortables: [folder, folderInsideFolder]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchivePage(
        initialFolder: folder.id,
      )));
      await tester.pumpAndSettle();
      expect(find.text(translate.imageArchive), findsOneWidget);
      expect(find.byType(ImageArchivePage), findsOneWidget);
      await tester.tap(find.byType(LibraryFolder));
      await tester.pumpAndSettle();
      expect(find.text(translate.imageArchive), findsNothing);
    });
  });
}
