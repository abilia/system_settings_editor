import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:package_info/package_info.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../../../../fakes/all.dart';
import '../../../../mocks/mock_bloc.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/register_fallback_values.dart';
import '../../../../test_helpers/tts.dart';

void main() {
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
              BlocProvider<SpeechSettingsCubit>(
                create: (context) => FakeSpeechSettingsCubit(),
              ),
              BlocProvider<ActivitiesBloc>(
                create: (context) => FakeActivitiesBloc(),
              ),
              BlocProvider<TimepillarCubit>(
                create: (context) => FakeTimepillarCubit(),
              ),
              BlocProvider<WakeLockCubit>(
                create: (context) => WakeLockCubit(
                  settingsDb: FakeSettingsDb(),
                  settingsStream: const Stream.empty(),
                  battery: FakeBattery(),
                  hasBattery: true,
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

  testWidgets('Log out page shows', (WidgetTester tester) async {
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
    expect(find.byType(AboutMemoplannerColumn), findsOneWidget);
    expect(find.byType(LoggedInAccountColumn), findsOneWidget);
    expect(find.byType(AboutDeviceColumn), findsOneWidget);
    expect(find.byType(ProducerColumn), findsOneWidget);
    await tester.scrollDown(-200);
    expect(
      find.byType(SearchForUpdateButton),
      Config.isMP ? findsOneWidget : findsNothing,
    );
    expect(
      find.text(translate.searchForUpdate),
      Config.isMP ? findsOneWidget : findsNothing,
    );
    await tester.scrollDown(200);
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
      await tester.scrollDown(-20);
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

  testWidgets('android settings available', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(const SystemSettingsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.android));
    await tester.pumpAndSettle();
  });
}

extension on WidgetTester {
  Future scrollDown(double dy) async {
    final center = getCenter(find.byType(AboutContent));
    await dragFrom(center, Offset(0.0, dy));
    await pump();
  }
}
