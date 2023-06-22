import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';

import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

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
      myPhotoFileId = '351d5e7d-0d87-4037-9829-538a14936125',
      myPhotoFileId2 = '351d5e7d-0d87-4037-9829-538a1asdasfsrg',
      path = '/images/Basic/Basic/bingo.gif',
      myPhotoPath = '/images/Basic/Basic/jello.gif',
      myPhotoPath2 = '/images/Basic/Basic/göllo.gif';

  const imageName = 'bingo';
  const myPhotoName = 'jello';
  const myPhotoName2 = 'göllo';

  final imageData = ImageArchiveData.fromJson('''
          {"name":"$imageName","fileId":"$fileId","file":"$path"}
          ''');
  final myPhotoData = ImageArchiveData.fromJson('''
          {"name":"$myPhotoName","fileId":"$myPhotoFileId","file":"$myPhotoPath"}
          ''');
  final myPhotoData2 = ImageArchiveData.fromJson('''
          {"name":"$myPhotoName2","fileId":"$myPhotoFileId2","file":"$myPhotoPath2"}
          ''');

  final image = Sortable.createNew<ImageArchiveData>(data: imageData);

  const folderName = 'Basic';
  const myPhotosFolderName = 'My photos';
  const myPhotosSubFolderName = 'Cute animals';

  final folderData = ImageArchiveData.fromJson('''
          {"name":"$folderName","fileId":"19da3060-be12-42f9-922e-7e1635293126","icon":"/images/Basic/Basic.png"}
          ''');
  final myPhotosFolderData = ImageArchiveData.fromJson('''
          {"name":"$myPhotosFolderName","fileId":"19da3060-be12-42f9-922e-7e1635293123","icon":"/images/Basic/My photos.png", "myPhotos": true}
          ''');
  final myPhotosSubFolderData = ImageArchiveData.fromJson('''
          {"name":"$myPhotosSubFolderName","fileId":"19da3060-be12-42f9-922e-7e1635293f<sdf","icon":"/images/Basic/YOYO.png"}
          ''');

  final folder =
      Sortable.createNew<ImageArchiveData>(data: folderData, isGroup: true);
  final myPhotosFolder = Sortable.createNew<ImageArchiveData>(
      data: myPhotosFolderData, isGroup: true);
  final myPhotosSubFolder = Sortable.createNew<ImageArchiveData>(
      data: myPhotosSubFolderData, isGroup: true, groupId: myPhotosFolder.id);

  const imageInFolderName = 'Folder image';
  final imageInFolder =
      Sortable.createNew<ImageArchiveData>(data: ImageArchiveData.fromJson('''
          {"name":"$imageInFolderName","fileId":"351d5e7d-0d87-4037-9829-538a14936129","file":"/images/Basic/Basic/infolder.gif"}
          '''), groupId: folder.id);
  final myPhoto = Sortable.createNew<ImageArchiveData>(
      data: myPhotoData, groupId: myPhotosFolder.id);
  final myPhotoInSubFolder = Sortable.createNew<ImageArchiveData>(
      data: myPhotoData2, groupId: myPhotosSubFolder.id);

  final folderData2 = ImageArchiveData.fromJson('''
          {"name":"folder2","fileId":"20da3060-be12-42f9-922e-7e1632993199","icon":"/images/Basic/Basic.png"}
          ''');
  final folderInsideFolder = Sortable.createNew<ImageArchiveData>(
      data: folderData2, isGroup: true, groupId: folder.id);

  NavObserver navObserver = NavObserver();

  tearDown(() => navObserver = NavObserver());

  Widget wrapWithMaterialApp(
    Widget widget, {
    String initialFolder = '',
    bool myPhotos = false,
  }) =>
      MaterialApp(
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
            BlocProvider<UserFileBloc>(
              create: (context) => UserFileBloc(
                fileStorage: FakeFileStorage(),
                syncBloc: FakeSyncBloc(),
                userFileRepository: FakeUserFileRepository(),
              ),
            ),
            BlocProvider<SpeechSettingsCubit>(
              create: (context) => FakeSpeechSettingsCubit(),
            ),
            BlocProvider<SortableArchiveCubit<ImageArchiveData>>(
              create: (context) => SortableArchiveCubit<ImageArchiveData>(
                sortableBloc: mockSortableBloc,
                myPhotos: myPhotos,
                initialFolderId: initialFolder,
              ),
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

  testWidgets('Selected Image is popped', (WidgetTester tester) async {
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
      final popped = navObserver.routesPoped;
      expect(popped, hasLength(1));
      final res = await popped.first.popped as SelectedImageData;
      expect(res.imageAndName.image, AbiliaFile.from(id: fileId, path: path));
      expect(res.imageAndName.name, image.data.name);
      expect(res.fromSearch, false);
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
        find.byType(AppBarHeading),
        contains: translate.imageArchive,
      );
    });
  });

  testWidgets('library navigation and header tts', (WidgetTester tester) async {
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

      // Assert heading contains image archive tts
      await tester.verifyTts(
        find.byType(AppBarHeading),
        contains: translate.imageArchive,
      );

      // Go to search page
      await tester.tap(find.byType(SearchButton));
      await tester.pumpAndSettle();

      // Assert search heading
      await tester.verifyTts(find.byType(AppBarHeading),
          exact: translate.searchImage);

      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();

      expect(find.byType(LibraryFolder), findsOneWidget);
      // Act - go into folder
      await tester.tap(find.byType(LibraryFolder));
      await tester.pumpAndSettle();

      // Assert heading contains folder tts
      await tester.verifyTts(
        find.byType(AppBarHeading),
        contains: folderName,
      );
      // Act -- go into image
      await tester.tap(find.byType(ArchiveImage));
      await tester.pumpAndSettle();

      // Assert - image name tts
      await tester.verifyTts(
        find.byType(AppBarHeading),
        contains: (imageInFolderName),
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
            of: find.byType(AppBarHeading),
            matching: find.textContaining(folderName)),
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
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const ImageArchivePage(),
          initialFolder: folder.id,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
      expect(find.byType(ArchiveImage), findsOneWidget);
      expect(find.byType(LibraryFolder), findsNothing);
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
      await tester.pumpWidget(wrapWithMaterialApp(const ImageArchivePage()));
      await tester.pumpAndSettle();
      expect(find.text(translate.imageArchive), findsOneWidget);
      expect(find.byType(ImageArchivePage), findsOneWidget);
      await tester.tap(find.byType(LibraryFolder));
      await tester.pumpAndSettle();
      expect(find.text(translate.imageArchive), findsNothing);
      expect(find.byType(LibraryHeading), findsNothing);
    });
  });

  testWidgets('Can go into sub folder in My photos',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      when(() => mockSortableBloc.state).thenAnswer(
        (_) => SortablesLoaded(
          sortables: [
            myPhotosFolder,
            myPhoto,
            myPhotosSubFolder,
            myPhotoInSubFolder,
          ],
        ),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const ImageArchivePage(),
          myPhotos: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(myPhotosFolder.data.name), findsOneWidget);
      await tester.tap(find.text(myPhotosFolder.data.name));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
      await tester.tap(find.text(myPhotosSubFolder.data.name));
      await tester.pumpAndSettle();
      expect(find.text(myPhotosFolder.data.name), findsNothing);
      expect(find.text(myPhotoInSubFolder.data.name), findsOneWidget);
      expect(find.byType(LibraryHeading), findsNothing);
    });
  });

  Future<void> pumpImageArchiveSearch(
    WidgetTester tester,
    bool myPhotos,
  ) async {
    await mockNetworkImages(() async {
      when(() => mockSortableBloc.state)
          .thenAnswer((_) => SortablesLoaded(sortables: [
                folder,
                folderInsideFolder,
                image,
                myPhotosFolder,
                myPhoto,
                myPhotosSubFolder,
                myPhotoInSubFolder,
              ]));
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const ImageArchivePage(),
          initialFolder: folder.id,
          myPhotos: myPhotos,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.find));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.find), findsOneWidget);
    });
  }

  testWidgets('Search image archive', (WidgetTester tester) async {
    await pumpImageArchiveSearch(tester, false);

    // Search for folder name
    await tester.enterText(find.byType(TextField), folder.data.name);
    await tester.pumpAndSettle();
    expect(find.text(translate.noMatchingImage), findsOneWidget);

    // Search for nonsense
    await tester.enterText(find.byType(TextField), 'fa4t4t');
    await tester.pumpAndSettle();
    expect(find.text(translate.noMatchingImage), findsOneWidget);

    // Search for myPhoto
    await tester.enterText(find.byType(TextField), myPhoto.data.name);
    await tester.pumpAndSettle();
    expect(find.text(translate.noMatchingImage), findsOneWidget);

    // Search for archive image name
    await tester.enterText(find.byType(TextField), image.data.name);
    await tester.pumpAndSettle();
    expect(find.text(image.data.name), findsNWidgets(2));

    // Press back returns to image archive
    await tester.tap(find.byType(PreviousButton));
    await tester.pumpAndSettle();
    expect(find.text(translate.imageArchive), findsOneWidget);
    expect(find.byType(ImageArchivePage), findsOneWidget);

    // Open a folder and tap search
    await tester.tap(find.byType(LibraryFolder));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.find));
    await tester.pumpAndSettle();

    // Expect - Search is empty
    expect(
        (find.byType(TextField).evaluate().single.widget as TextField)
            .controller
            ?.text,
        '');
    await tester.pumpAndSettle();

    // Search for nonsense
    await tester.enterText(find.byType(TextField), 'WGRwgrea');
    await tester.pumpAndSettle();
    expect(find.text(translate.noMatchingImage), findsOneWidget);
  });

  testWidgets('Search my photos', (WidgetTester tester) async {
    await pumpImageArchiveSearch(tester, true);

    // Search for folder name
    await tester.enterText(find.byType(TextField), folder.data.name);
    await tester.pumpAndSettle();
    expect(find.text(translate.noMatchingImage), findsOneWidget);

    // Search for nonsense
    await tester.enterText(find.byType(TextField), ' fa4t4t');
    await tester.pumpAndSettle();
    expect(find.text(translate.noMatchingImage), findsOneWidget);

    // Search for image archive name
    await tester.enterText(find.byType(TextField), image.data.name);
    await tester.pumpAndSettle();
    expect(find.text(translate.noMatchingImage), findsOneWidget);

    // Search for myPhoto
    await tester.enterText(find.byType(TextField), myPhoto.data.name);
    await tester.pumpAndSettle();
    expect(find.text(myPhoto.data.name), findsNWidgets(2));

    // Search for photo in sub folder
    await tester.enterText(
        find.byType(TextField), myPhotoInSubFolder.data.name);
    await tester.pumpAndSettle();
    expect(find.text(myPhotoInSubFolder.data.name), findsNWidgets(2));

    // Press back returns to image archive
    await tester.tap(find.byType(PreviousButton));
    await tester.pumpAndSettle();
    expect(find.text(translate.imageArchive), findsOneWidget);
    expect(find.byType(ImageArchivePage), findsOneWidget);
  });
}
