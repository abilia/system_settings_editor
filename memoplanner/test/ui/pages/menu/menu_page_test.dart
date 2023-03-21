import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';

import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:seagull_fakes/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';
import 'package:intl/intl.dart';

void main() {
  late MockSortableDb mockSortableDb;
  late MockGenericDb mockGenericDb;

  final myPhotosFolder = Sortable.createNew(
    data: const ImageArchiveData(myPhotos: true),
    isGroup: true,
    fixed: true,
  );
  final time = DateTime(2022, 05, 10, 13, 37);
  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;
    mockSortableDb = MockSortableDb();
    mockGenericDb = MockGenericDb();

    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value([]));
    when(() => mockGenericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => mockGenericDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    when(() => mockSortableDb.getAllNonDeleted()).thenAnswer(
      (invocation) => Future.value(
        <Sortable>[
          myPhotosFolder,
          Sortable.createNew(
            data: const ImageArchiveData(upload: true),
            isGroup: true,
            fixed: true,
          ),
          Sortable.createNew(
            data: const ImageArchiveData(),
            groupId: myPhotosFolder.id,
            sortOrder: 'c',
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
      ..ticker = Ticker.fake(initialTime: time)
      ..client = Fakes.client()
      ..database = FakeDatabase()
      ..genericDb = mockGenericDb
      ..sortableDb = mockSortableDb
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('Camera', () {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/image_picker');
    const newImagePath = 'AnewImagePath';
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return newImagePath;
      });

      log.clear();
    });

    testWidgets('Camera permanentlyDenied shows PermissionInfoDialog',
        (tester) async {
      setupPermissions({Permission.camera: PermissionStatus.permanentlyDenied});
      await tester.pumpApp();
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CameraButton));
      await tester.pumpAndSettle();
      expect(find.byType(PermissionInfoDialog), findsOneWidget);
    });

    testWidgets('saves image correctly (BUG SGC-1619)', (tester) async {
      await tester.pumpApp();
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CameraButton));
      await tester.pumpAndSettle();

      expect(
        log,
        <Matcher>[
          isMethodCall('pickImage', arguments: <String, dynamic>{
            'source': 0,
            'maxWidth': null,
            'maxHeight': null,
            'imageQuality': null,
            'cameraDevice': 0,
            'requestFullMetadata': true,
          }),
        ],
      );

      final capturedSortable =
          verify(() => mockSortableDb.insertAndAddDirty(captureAny())).captured;
      final lastCaptured =
          (capturedSortable.last as List).single as Sortable<ImageArchiveData>;
      expect(lastCaptured.deleted, false);
      expect(lastCaptured.fixed, false);
      expect(lastCaptured.isGroup, false);
      expect(lastCaptured.visible, true);
      expect(lastCaptured.sortOrder, 'b');
      expect(lastCaptured.type, SortableType.imageArchive);
      expect(lastCaptured.groupId, myPhotosFolder.id);
      expect(lastCaptured.data.icon, '');

      expect(lastCaptured.data.tags, isEmpty);
      expect(lastCaptured.data.upload, false);
      expect(lastCaptured.data.myPhotos, false);
      expect(lastCaptured.data.file, isNotEmpty);
      expect(lastCaptured.data.fileId, isNotEmpty);
      expect(lastCaptured.data.name, '5/10/2022');

      // Should probaly also check that the image is saved in UserFileBloc but
      // then we would probably need to mock the whole Bloc
    });
  }, skip: !Config.isMP);

  testWidgets('About button', (tester) async {
    await tester.pumpApp();
    await tester.tap(find.byType(MenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.handiInfo));
    await tester.pumpAndSettle();
    expect(find.byType(AboutContent), findsOneWidget);
    expect(find.byType(SearchForUpdateButton), findsNothing);
  }, skip: !Config.isMP);

  testWidgets(
      'BUG SGC-1655 - Wrong day in header in Menu/photo calendar/screensaver',
      (tester) async {
    final locale = Intl.getCurrentLocale();
    await tester.pumpApp();
    await tester.tap(find.byType(MenuButton));
    await tester.pumpAndSettle();
    expect(find.text(DateFormat.EEEE(locale).format(time)), findsOneWidget);
  }, skip: !Config.isMP);

  group('Settings', () {
    final weekCalendarStartViewSettings =
        Generic.createNew<MemoplannerSettingData>(
      data: MemoplannerSettingData.fromData(
        data: StartView.weekCalendar.index,
        identifier: FunctionsSettings.functionMenuStartViewKey,
      ),
    );
    final menuPageOffSetting = Generic.createNew<MemoplannerSettingData>(
      data: MemoplannerSettingData.fromData(
        data: false,
        identifier: DisplaySettings.functionMenuDisplayMenuKey,
      ),
    );
    final weekCalendarOffSetting = Generic.createNew<MemoplannerSettingData>(
      data: MemoplannerSettingData.fromData(
        data: false,
        identifier: DisplaySettings.functionMenuDisplayWeekKey,
      ),
    );

    testWidgets(
        'Removing week calendar from settings will keep you on menu page',
        (tester) async {
      await tester.pumpApp();
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SettingsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      when(() => mockGenericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value([weekCalendarOffSetting]));

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
    });

    testWidgets(
        'Removing menu from settings will navigate you to start view index',
        (tester) async {
      when(() => mockGenericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value([weekCalendarStartViewSettings]));
      await tester.pumpApp();
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SettingsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.appMenu));
      await tester.pumpAndSettle();

      when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer((_) =>
          Future.value([weekCalendarStartViewSettings, menuPageOffSetting]));

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(YesButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsNothing);
      expect(find.byType(WeekCalendarTab), findsOneWidget);
    });
  }, skip: !Config.isMP);
}
