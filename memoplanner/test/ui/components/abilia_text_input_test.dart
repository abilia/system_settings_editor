import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/ui/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';
import '../../test_helpers/tts.dart';

void main() {
  late SpeechSettingsCubit mockSpeechSettingsCubit;

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: BlocProvider<SpeechSettingsCubit>(
          create: (context) => mockSpeechSettingsCubit,
          child: Material(child: widget),
        ),
      );

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    setupFakeTts();

    mockSpeechSettingsCubit = MockSpeechSettingsCubit();
    when(() => mockSpeechSettingsCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockSpeechSettingsCubit.state)
        .thenAnswer((_) => const SpeechSettingsState(textToSpeech: true));

    when(() => mockSpeechSettingsCubit.close())
        .thenAnswer((_) => Future.value());

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('DefaultTextInputPage', () {
    group('TTS Play button', () {
      testWidgets(
        'TTS play button is hidden when there is no initial text',
        (WidgetTester tester) async {
          // Act
          await tester.pumpWidget(
            wrapWithMaterialApp(
              DefaultTextInput(
                maxLines: 1,
                icon: AbiliaIcons.edit,
                text: '',
                inputValid: (s) => true,
                autocorrect: false,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: const [],
                inputHeading: '',
                heading: '',
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Assert
          expect(find.byKey(TestKey.ttsPlayButton), findsNothing);
        },
      );

      testWidgets(
        'TTS play button hides when text is cleared',
        (WidgetTester tester) async {
          // Act
          await tester.pumpWidget(
            wrapWithMaterialApp(
              DefaultTextInput(
                maxLines: 1,
                icon: AbiliaIcons.edit,
                text: 'Initial Text',
                inputValid: (s) => true,
                autocorrect: false,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: const [],
                inputHeading: '',
                heading: '',
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Assert
          expect(find.byKey(TestKey.ttsPlayButton), findsOneWidget);

          // Act
          await tester.enterText(find.byKey(TestKey.input), '');
          await tester.pumpAndSettle();

          // Assert
          expect(find.byKey(TestKey.ttsPlayButton), findsNothing);
        },
      );

      testWidgets(
        'TTS play button is shown when there is initial text',
        (WidgetTester tester) async {
          // Act
          await tester.pumpWidget(
            wrapWithMaterialApp(
              DefaultTextInput(
                maxLines: 1,
                icon: AbiliaIcons.edit,
                text: 'Initial Text',
                inputValid: (s) => true,
                autocorrect: false,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: const [],
                inputHeading: '',
                heading: '',
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Assert
          expect(find.byKey(TestKey.ttsPlayButton), findsOneWidget);
        },
      );

      testWidgets(
        'TTS play button is shown when text is entered',
        (WidgetTester tester) async {
          // Act
          await tester.pumpWidget(
            wrapWithMaterialApp(
              DefaultTextInput(
                maxLines: 1,
                icon: AbiliaIcons.edit,
                text: '',
                inputValid: (s) => true,
                autocorrect: false,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: const [],
                inputHeading: '',
                heading: '',
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Assert
          expect(find.byKey(TestKey.ttsPlayButton), findsNothing);

          // Act
          await tester.enterText(find.byKey(TestKey.input), 'Entered Text');
          await tester.pumpAndSettle();

          // Assert
          expect(find.byKey(TestKey.ttsPlayButton), findsOneWidget);
        },
      );

      testWidgets(
        'TTS play button plays TTS speech',
        (WidgetTester tester) async {
          const ttsText = 'This is tts text';

          // Act
          await tester.pumpWidget(
            wrapWithMaterialApp(
              DefaultTextInput(
                maxLines: 1,
                icon: AbiliaIcons.edit,
                text: ttsText,
                inputValid: (s) => true,
                autocorrect: false,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: const [],
                inputHeading: '',
                heading: '',
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Assert
          await tester.verifyTts(
            find.byKey(TestKey.ttsPlayButton),
            exact: ttsText,
            useTap: true,
          );
        },
      );

      testWidgets(
        'Speak every word outputs last word in sentence only',
        (WidgetTester tester) async {
          when(() => mockSpeechSettingsCubit.state).thenAnswer(
            (_) => const SpeechSettingsState(
              textToSpeech: true,
              speakEveryWord: true,
            ),
          );

          const ttsText = 'This is ';

          // Act
          await tester.pumpWidget(
            wrapWithMaterialApp(
              DefaultTextInput(
                maxLines: 1,
                icon: AbiliaIcons.edit,
                text: '',
                inputValid: (s) => true,
                autocorrect: false,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: const [],
                inputHeading: '',
                heading: '',
              ),
            ),
          );
          await tester.pumpAndSettle();

          await tester.enterText(find.byKey(TestKey.input), ttsText);
          await tester.pumpAndSettle();

          // Assert
          await tester.verifyTts(
            find.byKey(TestKey.input),
            exact: 'is',
            useTap: true,
          );
        },
        skip: Config.isMPGO,
      );

      testWidgets(
        'SGC-1871 don\'t speak every word when text to speech is false',
        (WidgetTester tester) async {
          when(() => mockSpeechSettingsCubit.state).thenAnswer(
            (_) => const SpeechSettingsState(
              textToSpeech: false,
              speakEveryWord: true,
            ),
          );

          const ttsText = 'This is ';

          // Act
          await tester.pumpWidget(
            wrapWithMaterialApp(
              DefaultTextInput(
                maxLines: 1,
                icon: AbiliaIcons.edit,
                text: '',
                inputValid: (s) => true,
                autocorrect: false,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: const [],
                inputHeading: '',
                heading: '',
              ),
            ),
          );
          await tester.pumpAndSettle();

          await tester.enterText(find.byKey(TestKey.input), ttsText);
          await tester.pumpAndSettle();

          // Assert
          await tester.verifyNoTts();
        },
        skip: Config.isMPGO,
      );
    });
  });
}
