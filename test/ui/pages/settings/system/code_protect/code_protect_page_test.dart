import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/system/code_protect/change_code_protect_page.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';
import '../../../../../test_helpers/verify_generic.dart';

void main() {
  GenericResponse genericResponse = () => [];
  late MockGenericDb genericDb;

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    genericDb = MockGenericDb();
    when(() => genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(genericResponse()));
    when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => genericDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..ticker = Ticker.fake(
        initialTime: DateTime(2021, 10, 29, 09, 20),
      )
      ..client = Fakes.client(genericResponse: genericResponse)
      ..database = FakeDatabase()
      ..genericDb = genericDb
      ..battery = FakeBattery()
      ..init();
  });

  tearDown(() {
    GetIt.I.reset();
    genericResponse = () => [];
  });

  group('code protect settings page', () {
    testWidgets('shows', (tester) async {
      await tester._goToCodeProtectPage();
      expect(find.byType(CodeProtectSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });

    testWidgets('protect settings saved', (tester) async {
      await tester._goToCodeProtectPage();

      await tester.tap(find.byIcon(AbiliaIcons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: CodeProtectSettings.protectSettingsKey,
        matcher: isTrue,
      );
    });

    testWidgets('protect code protect saved', (tester) async {
      await tester._goToCodeProtectPage();

      await tester.tap(find.byIcon(AbiliaIcons.fullScreen));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: CodeProtectSettings.protectCodeProtectKey,
        matcher: isTrue,
      );
    });

    testWidgets('protect android settings saved', (tester) async {
      await tester._goToCodeProtectPage();

      await tester.tap(
        find.byIcon(AbiliaIcons.pastPictureFromWindowsClipboard),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: CodeProtectSettings.protectAndroidSettingsKey,
        matcher: isTrue,
      );
    });

    testWidgets('can change code protect code', (tester) async {
      const placeHoderText = '----';
      const newCode = '0808';
      await tester._goToCodeProtectPage();

      expect(find.text(CodeProtectSettings.defaultCode), findsOneWidget);
      await tester.tap(find.byType(PickField));
      await tester.pumpAndSettle();

      expect(find.text(placeHoderText), findsOneWidget);
      await tester.enterText(find.byType(TextField), newCode);
      await tester.pumpAndSettle();

      expect(find.text(newCode), findsOneWidget);
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();

      expect(find.text(newCode), findsNothing);
      expect(find.text(placeHoderText), findsOneWidget);
      await tester.enterText(find.byType(TextField), newCode);

      expect(find.text(newCode), findsOneWidget);
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();

      expect(find.text(CodeProtectSettings.defaultCode), findsNothing);
      expect(find.text(newCode), findsOneWidget);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: CodeProtectSettings.codeKey,
        matcher: newCode,
      );
    });

    testWidgets('changing code protect code - errors', (tester) async {
      await tester._goToCodeProtectPage();

      await tester.tap(find.byType(PickField));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '123');
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '1234');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CancelButton));
      await tester.pumpAndSettle();
      expect(find.byType(ChangeCodeProtectPage), findsNothing);
      expect(find.text('1234'), findsNothing);
      expect(find.text(CodeProtectSettings.defaultCode), findsOneWidget);
    });
  }, skip: !Config.isMP);

  group('shows code protect on screens', () {
    testWidgets('settings is protected', (tester) async {
      // Arrange
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: CodeProtectSettings.protectSettingsKey,
              ),
            ),
          ];

      await tester._goToSettings();
      expect(find.byType(CodeProtectPage), findsOneWidget);

      await tester._enterCode(CodeProtectSettings.defaultCode);
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('android settings is protected', (tester) async {
      // Arrange
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: CodeProtectSettings.protectAndroidSettingsKey,
              ),
            ),
          ];
      // Act
      await tester._goToSettings();
      await tester.tap(find.byIcon(AbiliaIcons.technicalSettings));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byIcon(AbiliaIcons.pastPictureFromWindowsClipboard),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CodeProtectPage), findsOneWidget);
    });

    testWidgets('code protect is protected, error when wrong code',
        (tester) async {
      // Assert
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: CodeProtectSettings.protectCodeProtectKey,
              ),
            ),
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: '1234',
                identifier: CodeProtectSettings.codeKey,
              ),
            ),
          ];
      // Act
      await tester._goToSettings();
      await tester.tap(find.byIcon(AbiliaIcons.technicalSettings));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.numericKeyboard));
      await tester.pumpAndSettle();
      expect(find.byType(CodeProtectPage), findsOneWidget);
      await tester._enterCode('1111');
      expect(find.byType(ErrorDialog), findsOneWidget);
      await tester.tap(
        find.descendant(
            of: find.byType(ErrorDialog),
            matching: find.byType(PreviousButton)),
      );
      expect(find.byType(CodeProtectSettingsPage), findsNothing);
      await tester.pumpAndSettle();
      await tester._enterCode('1234');
      expect(find.byType(CodeProtectSettingsPage), findsOneWidget);
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future<void> _goToSettings() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
  }

  Future<void> _goToCodeProtectPage() async {
    await _goToSettings();
    await tap(find.byIcon(AbiliaIcons.technicalSettings));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.numericKeyboard));
    await pumpAndSettle();
  }

  Future<void> _enterCode(String code) async {
    await enterText(find.byType(TextField), code);
    await pumpAndSettle();
  }
}
