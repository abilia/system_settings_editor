// @dart=2.9

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info/package_info.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../mocks.dart';

void main() {
  MockSettingsDb mockSettingsDb;
  MockAuthenticationBloc mockAuthenticationBloc;
  MockActivitiesBloc mockActivitiesBloc;
  MockTimepillarBloc mockTimepillarBloc;
  final user = User(
      id: 1,
      name: 'Slartibartfast',
      username: 'Zaphod Beeblebrox',
      type: 'type');

  final translate = Locales.language.values.first;
  setUp(() async {
    await initializeDateFormatting();
    mockSettingsDb = MockSettingsDb();
    mockAuthenticationBloc = MockAuthenticationBloc();
    mockTimepillarBloc = MockTimepillarBloc();
    mockActivitiesBloc = MockActivitiesBloc();
    when(mockActivitiesBloc.state).thenReturn(ActivitiesNotLoaded());
    final userDb = MockUserDb();
    when(userDb.getUser()).thenReturn(user);
    GetItInitializer()
      ..flutterTts = MockFlutterTts()
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
        localizationsDelegates: [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        builder: (context, child) => MockAuthenticatedBlocsProvider(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthenticationBloc>(
                  create: (context) => mockAuthenticationBloc),
              BlocProvider<SettingsBloc>(
                create: (context) => SettingsBloc(settingsDb: mockSettingsDb),
              ),
              BlocProvider<ActivitiesBloc>(
                create: (context) => mockActivitiesBloc,
              ),
              BlocProvider<TimepillarBloc>(
                create: (context) => mockTimepillarBloc,
              )
            ],
            child: child,
          ),
        ),
        home: widget,
      );

  testWidgets('Settings page shows', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.power_off_on), findsOneWidget);
    await tester.tap(find.byIcon(AbiliaIcons.power_off_on));
    await tester.pumpAndSettle();
    expect(find.byType(LogoutButton), findsOneWidget);
    expect(find.byType(ProfilePictureNameAndEmail), findsOneWidget);
  });

  testWidgets('tts', (WidgetTester tester) async {
    when(mockSettingsDb.textToSpeech).thenReturn(true);

    await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.verifyTts(find.byIcon(AbiliaIcons.power_off_on),
        exact: translate.logout);
    await tester.tap(find.byIcon(AbiliaIcons.power_off_on));
    await tester.pumpAndSettle();
    await tester.verifyTts(find.byType(LogoutButton), exact: translate.logout);
    await tester.verifyTts(find.text(user.name), exact: user.name);
    await tester.verifyTts(find.text(user.username), exact: user.username);
  });

  testWidgets('Tts info page', (WidgetTester tester) async {
    when(mockSettingsDb.textToSpeech).thenReturn(true);
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
    when(mockSettingsDb.textToSpeech).thenReturn(true);
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
        .where((s) => s.isNotEmpty);
    for (var text in textWidgets) {
      await tester.verifyTts(find.text(text), exact: text);
    }
  });

  testWidgets('code protect visible', (WidgetTester tester) async {
    setupPermissions();
    await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.numeric_keyboard));
    await tester.pumpAndSettle();
    expect(find.byType(CodeProtectPage), findsOneWidget);
  });

  testWidgets('android settings availible', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byIcon(AbiliaIcons.past_picture_from_windows_clipboard));
    await tester.pumpAndSettle();
  });
}
