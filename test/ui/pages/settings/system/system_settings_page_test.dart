import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:package_info/package_info.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:collection/collection.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../fakes/all.dart';
import '../../../../mocks/mock_bloc.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/register_fallback_values.dart';
import '../../../../test_helpers/tts.dart';

void main() {
  late MockSettingsDb mockSettingsDb;
  const user = User(
      id: 1,
      name: 'Slartibartfast',
      username: 'Zaphod Beeblebrox',
      type: 'type');

  final translate = Locales.language.values.first;
  setUp(() async {
    await initializeDateFormatting();
    setupFakeTts();
    registerFallbackValues();
    mockSettingsDb = MockSettingsDb();
    when(() => mockSettingsDb.textToSpeech).thenReturn(true);
    final userDb = MockUserDb();
    when(() => userDb.getUser()).thenReturn(user);
    GetItInitializer()
      ..userDb = userDb
      ..packageInfo = PackageInfo(
          appName: 'appName',
          packageName: 'packageName',
          version: 'version',
          buildNumber: 'buildNumber')
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
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
              BlocProvider<SettingsCubit>(
                create: (context) => SettingsCubit(settingsDb: mockSettingsDb),
              ),
              BlocProvider<ActivitiesBloc>(
                create: (context) => FakeActivitiesBloc(),
              ),
              BlocProvider<TimepillarCubit>(
                create: (context) => FakeTimepillarCubit(),
              ),
              BlocProvider<WakeLockCubit>(
                create: (context) => WakeLockCubit(
                  screenTimeoutCallback:
                      Future.value(const Duration(minutes: 30)),
                  memoSettingsBloc: context.read<MemoplannerSettingBloc>(),
                  battery: FakeBattery(),
                ),
              ),
              BlocProvider<TimerCubit>(
                create: (context) => MockTimerCubit(),
              ),
            ],
            child: child!,
          ),
        ),
        home: widget,
      );

  testWidgets('Settings page shows', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(const SystemSettingsPage()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.powerOffOn), findsOneWidget);
    await tester.tap(find.byIcon(AbiliaIcons.powerOffOn));
    await tester.pumpAndSettle();
    expect(find.byType(LogoutButton), findsOneWidget);
    expect(find.byType(ProfilePictureNameAndEmail), findsOneWidget);
  });

  testWidgets('tts', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(const SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.verifyTts(find.byIcon(AbiliaIcons.powerOffOn),
        exact: translate.logout);
    await tester.tap(find.byIcon(AbiliaIcons.powerOffOn));
    await tester.pumpAndSettle();
    await tester.verifyTts(find.byType(LogoutButton), exact: translate.logout);
    await tester.verifyTts(find.text(user.name), exact: user.name);
    await tester.verifyTts(find.text(user.username), exact: user.username);
  });

  testWidgets('About page', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(const SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.information));
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);
    expect(
      find.byType(SearchForUpdateButton),
      Config.isMP ? findsOneWidget : findsNothing,
    );
    expect(
      find.text(translate.searchForUpdate),
      Config.isMP ? findsOneWidget : findsNothing,
    );
    final textWidgets = find
        .byType(Text)
        .evaluate()
        .whereType<StatelessElement>()
        .map((e) => e.widget)
        .whereType<Text>()
        .map((t) => t.data)
        .whereNotNull()
        .where((s) => s.isNotEmpty)
        // Need to exclude these two fields because tts sees them as one
        .where((s) => s != 'System' && s != 'About');
    for (var text in textWidgets) {
      await tester.verifyTts(find.text(text), exact: text);
    }
  });

  testWidgets('code protect visible', (WidgetTester tester) async {
    setupPermissions();
    await tester.pumpWidget(wrapWithMaterialApp(const SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.numericKeyboard));
    await tester.pumpAndSettle();
    expect(find.byType(CodeProtectSettingsPage), findsOneWidget);
  });

  testWidgets('android settings availible', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(const SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.pastPictureFromWindowsClipboard));
    await tester.pumpAndSettle();
  });
}
