import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info/package_info.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:collection/collection.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../fakes/all.dart';
import '../../../../mocks/shared.mocks.dart';
import '../../../../test_helpers/tts.dart';

void main() {
  late MockSettingsDb mockSettingsDb;
  final user = User(
      id: 1,
      name: 'Slartibartfast',
      username: 'Zaphod Beeblebrox',
      type: 'type');

  final translate = Locales.language.values.first;
  setUp(() async {
    await initializeDateFormatting();
    setupFakeTts();
    mockSettingsDb = MockSettingsDb();
    when(mockSettingsDb.textToSpeech).thenReturn(true);
    final userDb = MockUserDb();
    when(userDb.getUser()).thenReturn(user);
    GetItInitializer()
      ..userDb = userDb
      ..packageInfo = PackageInfo(
          appName: 'appName',
          packageName: 'packageName',
          version: 'version',
          buildNumber: 'buildNumber')
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = MockDatabase()
      ..init();
  });

  tearDown(GetIt.I.reset);

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        builder: (context, child) => FakeAuthenticatedBlocsProvider(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthenticationBloc>(
                  create: (context) => FakeAuthenticationBloc()),
              BlocProvider<SettingsBloc>(
                create: (context) => SettingsBloc(settingsDb: mockSettingsDb),
              ),
              BlocProvider<ActivitiesBloc>(
                create: (context) => FakeActivitiesBloc(),
              ),
              BlocProvider<TimepillarBloc>(
                create: (context) => FakeTimepillarBloc(),
              )
            ],
            child: child!,
          ),
        ),
        home: widget,
      );

  testWidgets('Settings page shows', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.powerOffOn), findsOneWidget);
    await tester.tap(find.byIcon(AbiliaIcons.powerOffOn));
    await tester.pumpAndSettle();
    expect(find.byType(LogoutButton), findsOneWidget);
    expect(find.byType(ProfilePictureNameAndEmail), findsOneWidget);
  });

  testWidgets('tts', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.verifyTts(find.byIcon(AbiliaIcons.powerOffOn),
        exact: translate.logout);
    await tester.tap(find.byIcon(AbiliaIcons.powerOffOn));
    await tester.pumpAndSettle();
    await tester.verifyTts(find.byType(LogoutButton), exact: translate.logout);
    await tester.verifyTts(find.text(user.name), exact: user.name);
    await tester.verifyTts(find.text(user.username), exact: user.username);
  });

  testWidgets('Tts info page', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(InfoButton));
    await tester.pumpAndSettle();
    expect(find.byType(LongPressInfoDialog), findsOneWidget);
    await tester.verifyTts(find.text(translate.longPressInfoText),
        exact: translate.longPressInfoText);
  });

  testWidgets('Tts switched off', (WidgetTester tester) async {
    when(mockSettingsDb.textToSpeech).thenReturn(false);
    await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(InfoButton));
    await tester.pumpAndSettle();
    expect(find.byType(LongPressInfoDialog), findsOneWidget);
    await tester.verifyNoTts(find.text(translate.longPressInfoText));
  });

  testWidgets('About page', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.information));
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);
    final textWidgets = find
        .byType(Text)
        .evaluate()
        .whereType<StatelessElement>()
        .map((e) => e.widget)
        .whereType<Text>()
        .map((t) => t.data)
        .whereNotNull()
        .where((s) => s.isNotEmpty);
    for (var text in textWidgets) {
      await tester.verifyTts(find.text(text), exact: text);
    }
  });

  testWidgets('code protect visible', (WidgetTester tester) async {
    setupPermissions();
    await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.numericKeyboard));
    await tester.pumpAndSettle();
    expect(find.byType(CodeProtectPage), findsOneWidget);
  });

  testWidgets('android settings availible', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.pastPictureFromWindowsClipboard));
    await tester.pumpAndSettle();
  });
}
