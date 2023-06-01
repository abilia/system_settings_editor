import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:seagull_fakes/all.dart';

import '../../../../fakes/all.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/app_pumper.dart';
import '../../../../test_helpers/tts.dart';

void main() {
  group('Speech support settings page', () {
    final Iterable<Generic> generics = [];
    late MockGenericDb genericDb;
    late MockVoiceDb voiceDb;

    setUp(() async {
      setupPermissions();
      setupFakeTts();

      genericDb = MockGenericDb();
      when(() => genericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) async => generics);
      when(() => genericDb.getAllDirty()).thenAnswer((_) async => []);
      when(() => genericDb.insertAndAddDirty(any()))
          .thenAnswer((_) async => true);
      when(() => genericDb.getById(any())).thenAnswer((_) async => null);
      when(() => genericDb.insert(any())).thenAnswer((_) async {});

      voiceDb = MockVoiceDb();
      when(() => voiceDb.textToSpeech).thenReturn(true);
      when(() => voiceDb.speechRate).thenReturn(100);
      when(() => voiceDb.speakEveryWord).thenReturn(false);
      when(() => voiceDb.voice).thenReturn('');
      when(() => voiceDb.setTextToSpeech(any())).thenAnswer((_) async {});
      when(() => voiceDb.setVoice(any())).thenAnswer((_) async {});

      final ttsHandler = MockTtsHandler();
      when(() => ttsHandler.availableVoices).thenAnswer((_) async => ['en']);
      when(() => ttsHandler.setVoice(any())).thenAnswer((_) async {});

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..ticker = Ticker.fake(initialTime: DateTime(2021, 04, 17, 09, 20))
        ..client = Fakes.client(
          genericResponse: () => generics,
          activityResponse: () => [],
          voicesResponse: () => [
            ...['en', 'sv'].map(
              (lang) => {
                'name': lang,
                'lang': lang,
                'countryCode': 'SE',
                'file': {
                  'downloadUrl': 'https://voices.$lang',
                  'md5': 'md5_$lang',
                  'size': 0,
                },
              },
            )
          ],
        )
        ..database = FakeDatabase()
        ..genericDb = genericDb
        ..sortableDb = FakeSortableDb()
        ..battery = FakeBattery()
        ..settingsDb = FakeSettingsDb()
        ..ttsHandler = ttsHandler
        ..deviceDb = FakeDeviceDb()
        ..voiceDb = voiceDb
        ..directories = Directories(
          applicationSupport: Directory('applicationSupport'),
          documents: Directory('documents'),
          temp: Directory('temp'),
        )
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
      when(() => voiceDb.textToSpeech).thenAnswer((_) => false);

      await tester.goToSpeechSettingsPage();
      expect(find.byType(TtsPlayButton), findsNothing);
      expect(find.byType(AbiliaSlider), findsNothing);
      expect(find.byType(PickField), findsNothing);
    });

    testWidgets('When TTS setting true, tts options available', (tester) async {
      await tester.goToSpeechSettingsPage();
      expect(find.byType(TtsPlayButton), findsOneWidget);
      expect(find.byType(AbiliaSlider), findsOneWidget);
      expect(find.byType(PickField), findsOneWidget);
    });

    testWidgets('Tapping voice pickfield shows VoicesPage', (tester) async {
      await tester.goToSpeechSettingsPage();
      await tester.tap(find.byType(PickField));
      await tester.pumpAndSettle();
      expect(find.byType(VoicesPage), findsOneWidget);
    });

    const en = 'en: 0 MB', sv = 'sv: 0 MB';
    testWidgets('Changing language changes available voices', (tester) async {
      await tester.goToSpeechSettingsPage();
      await tester.tap(find.byType(PickField));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(RadioField<String>, en), findsOneWidget);
      expect(find.widgetWithText(RadioField<String>, sv), findsNothing);
      await tester.binding.setLocale('sv', 'se');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(RadioField<String>, sv), findsOneWidget);
      expect(find.widgetWithText(RadioField<String>, en), findsNothing);
    });

    testWidgets('Changing language unsets selected voice SGC-1783',
        (tester) async {
      when(() => voiceDb.voice).thenReturn('en');
      await tester.goToSpeechSettingsPage();
      expect(find.widgetWithText(PickField, 'en'), findsOneWidget);
      await tester.binding.setLocale('sv', 'se');
      await tester.pumpAndSettle();
      expect(find.byType(PickField), findsNothing);
      await tester.tap(find.byType(TextToSpeechSwitch));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(PickField, const SV().noVoicesInstalled),
        findsOneWidget,
      );
      expect(find.widgetWithText(PickField, 'en'), findsNothing);
      expect(find.widgetWithText(PickField, 'sv'), findsNothing);
    });

    testWidgets('Delete voice does not select other voice SGC-1783',
        (tester) async {
      when(() => voiceDb.voice).thenReturn('en');
      await tester.goToSpeechSettingsPage();
      await tester.tap(find.byType(PickField));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(RadioField<String>, en), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.deleteAllClear));
      await tester.pumpAndSettle();
      expect(find.byIcon(AbiliaIcons.deleteAllClear), findsNothing);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(find.byType(VoicesPage), findsNothing);
      expect(find.byType(SpeechSupportSettingsPage), findsOneWidget);
      await tester.tap(find.byType(TextToSpeechSwitch));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(PickField, const EN().noVoicesInstalled),
        findsOneWidget,
      );
      expect(find.widgetWithText(PickField, 'en'), findsNothing);
      expect(find.widgetWithText(PickField, 'sv'), findsNothing);
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
