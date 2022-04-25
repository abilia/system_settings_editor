import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/tts/tts_handler.dart';

import 'package:seagull/ui/all.dart';

import '../../fakes/all.dart';
import '../../test_helpers/register_fallback_values.dart';
import '../../test_helpers/tts.dart';

void main() {
  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>(
              create: (context) => SettingsCubit(
                settingsDb: FakeSettingsDb(),
              ),
            ),
          ],
          child: widget,
        ),
      );

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    setupFakeTts();

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..ttsHandler = Config.isMP
          ? AcapelaTtsHandler(initialize: false)
          : FlutterTtsHandler(FlutterTts())
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
              DefaultTextInputPage(
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
              DefaultTextInputPage(
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
              DefaultTextInputPage(
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
              DefaultTextInputPage(
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
              DefaultTextInputPage(
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
    });
  });
}
