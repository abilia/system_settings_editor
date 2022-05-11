import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/generic/generic.dart';
import 'package:seagull/repository/ticker.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/system/speech_support_settings_page.dart';
import 'package:seagull/ui/pages/settings/system/voices_page.dart';

import '../../../../fakes/all.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/app_pumper.dart';
import '../../../../test_helpers/tts.dart';

void main() {
  group('Speech support settings page', () {
    Iterable<Generic> generics = [];
    late MockGenericDb genericDb;
    late MockSettingsDb settingsDb;

    setUp(() async {
      setupPermissions();
      setupFakeTts();

      genericDb = MockGenericDb();
      when(() => genericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value(generics));
      when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
      when(() => genericDb.insertAndAddDirty(any()))
          .thenAnswer((_) => Future.value(true));
      when(() => genericDb.getById(any()))
          .thenAnswer((_) => Future.value(null));
      when(() => genericDb.insert(any())).thenAnswer((_) async {});

      settingsDb = MockSettingsDb();
      when(() => settingsDb.textToSpeech).thenAnswer((_) => true);
      when(() => settingsDb.alwaysUse24HourFormat).thenAnswer((_) => true);
      when(() => settingsDb.setAlwaysUse24HourFormat(any()))
          .thenAnswer((_) => Future.value());
      when(() => settingsDb.leftCategoryExpanded).thenReturn(true);
      when(() => settingsDb.setLeftCategoryExpanded(any()))
          .thenAnswer((_) => Future.value());
      when(() => settingsDb.rightCategoryExpanded).thenReturn(true);
      when(() => settingsDb.setRightCategoryExpanded(any()))
          .thenAnswer((_) => Future.value());
      when(() => settingsDb.speechRate).thenAnswer((_) => 100);
      when(() => settingsDb.speakEveryWord).thenAnswer((_) => false);
      when(() => settingsDb.voice).thenAnswer((_) => '');

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..ticker = Ticker.fake(initialTime: DateTime(2021, 04, 17, 09, 20))
        ..client = Fakes.client(genericResponse: () => generics)
        ..database = FakeDatabase()
        ..genericDb = genericDb
        ..battery = FakeBattery()
        ..settingsDb = settingsDb
        ..ttsHandler = AcapelaTtsHandler()
        ..init();
    });

    tearDown(GetIt.I.reset);

    testWidgets('The page shows', (tester) async {
      await tester.goToSpeechSettingsPage();
      expect(find.byType(SpeechSupportSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
      expect(find.byType(TextToSpeechSwitch), findsOneWidget);
    });

    testWidgets('Tts info page', (WidgetTester tester) async {
      await tester.goToSpeechSettingsPage();
      await tester.tap(find.byType(InfoButton));
      await tester.pumpAndSettle();
      expect(find.byType(LongPressInfoDialog), findsOneWidget);
    });

    testWidgets('When TTS setting false, no other options should be available',
        (tester) async {
      when(() => settingsDb.textToSpeech).thenAnswer((_) => false);

      await tester.goToSpeechSettingsPage();
      expect(find.byType(TtsTestButton), findsNothing);
      expect(find.byType(AbiliaSlider), findsNothing);
      expect(find.byType(PickField), findsNothing);
    });

    testWidgets('When TTS setting true, tts options available', (tester) async {
      await tester.goToSpeechSettingsPage();
      expect(find.byType(TtsTestButton), findsOneWidget);
      expect(find.byType(AbiliaSlider), findsOneWidget);
      expect(find.byType(PickField), findsOneWidget);
    });

    testWidgets('If voice not set enabling tts shows VoicesPage',
        (tester) async {
      when(() => settingsDb.textToSpeech).thenAnswer((_) => false);

      await tester.goToSpeechSettingsPage();
      await tester.tap(find.byType(TextToSpeechSwitch));
      await tester.pumpAndSettle();
      expect(find.byType(VoicesPage), findsOneWidget);
    });

    testWidgets('Tapping voice pickfield shows VoicesPage', (tester) async {
      await tester.goToSpeechSettingsPage();
      await tester.tap(find.byType(PickField));
      await tester.pumpAndSettle();
      expect(find.byType(VoicesPage), findsOneWidget);
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future<void> goToSpeechSettingsPage() async {
    await pumpApp();

    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.technicalSettings));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.speakText));
    await pumpAndSettle();
  }
}
