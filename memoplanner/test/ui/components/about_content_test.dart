import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:seagull_fakes/all.dart';
import 'package:uuid/uuid.dart';

import '../../fakes/all.dart';
import '../../mocks/mocks.dart';

void main() {
  final mockUserDb = MockUserDb();
  final mockDeviceDb = MockDeviceDb();
  const user = User(
    id: 1,
    name: 'Slartibartfast',
    username: 'Zaphod Beeblebrox',
    type: 'type',
  );

  final activatedLicense = DeviceLicense.fromJson({
    'serialNumber': 'SN123',
    'product': 'Dummy Product',
    'endTime': 1691510400000,
    'licenseKey': 'BACDFGAHJKLANOAP'
  });

  final nonActivatedLicense = DeviceLicense.fromJson({
    'serialNumber': 'SN123',
    'product': 'Dummy Product',
    'endTime': 0,
    'licenseKey': 'BACDFGAHJKLANOAP'
  });

  setUp(() async {
    when(() => mockUserDb.getUser()).thenReturn(user);
    when(() => mockDeviceDb.getDeviceLicense()).thenReturn(activatedLicense);
    when(() => mockDeviceDb.getSupportId())
        .thenAnswer((_) => Future.value(const Uuid().v4()));
    when(() => mockDeviceDb.serialId).thenAnswer((_) => const Uuid().v4());
    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..userDb = mockUserDb
      ..deviceDb = mockDeviceDb
      ..init();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  Future<void> pumpAboutContent(
    WidgetTester tester, {
    isDialog = false,
  }) async =>
      tester.pumpWidget(
        BlocProvider(
          create: (context) => NavigationCubit(),
          child: Builder(
            builder: (context) {
              return MaterialApp(
                home: BlocProvider<SpeechSettingsCubit>(
                  create: (context) => FakeSpeechSettingsCubit(),
                  child: isDialog ? const AboutDialog() : const AboutPage(),
                ),
              );
            },
          ),
        ),
      );

  testWidgets('About Page', (WidgetTester tester) async {
    await pumpAboutContent(tester);

    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.byType(AboutContent), findsOneWidget);
    expect(find.byType(AboutMemoplannerColumn), findsOneWidget);
    expect(find.byType(LoggedInAccountColumn), findsOneWidget);
    expect(find.byType(AboutDeviceColumn), findsOneWidget);
    expect(find.byType(ProducerColumn), findsOneWidget);

    final center = tester.getCenter(find.byType(AboutPage));
    await tester.dragFrom(center, const Offset(0.0, -200));
    await tester.pumpAndSettle();
    expect(find.byType(SearchForUpdateButton),
        Config.isMP ? findsOneWidget : findsNothing);
  });

  testWidgets('About Dialog', (WidgetTester tester) async {
    await pumpAboutContent(tester, isDialog: true);

    expect(find.byType(AboutDialog), findsOneWidget);
    expect(find.byType(AboutContent), findsOneWidget);
    expect(find.byType(AboutMemoplannerColumn), findsOneWidget);
    expect(find.byType(LoggedInAccountColumn), findsOneWidget);
    expect(find.byType(AboutDeviceColumn), findsOneWidget);
    expect(find.byType(ProducerColumn), findsOneWidget);
    expect(find.byType(SearchForUpdateButton), findsNothing);
  });

  testWidgets('User logged out', (WidgetTester tester) async {
    when(() => mockUserDb.getUser()).thenReturn(null);
    await pumpAboutContent(tester);

    expect(find.byType(LoggedInAccountColumn), findsNothing);
  });

  testWidgets('Activated license', (WidgetTester tester) async {
    await pumpAboutContent(tester);

    final doubleTextsInAboutColumn = find
        .descendant(
          of: find.byType(AboutMemoplannerColumn),
          matching: find.byType(DoubleText),
        )
        .evaluate();

    expect(doubleTextsInAboutColumn.length, 3);
    expect(find.text('BACD-FGAH-JKLA-NOAP'), findsOneWidget);
    expect(find.text('8/8/2023'), findsOneWidget);
  });

  testWidgets('Non activated license', (WidgetTester tester) async {
    when(() => mockDeviceDb.getDeviceLicense()).thenReturn(nonActivatedLicense);
    await pumpAboutContent(tester);

    final doubleTextsInAboutColumn = find
        .descendant(
          of: find.byType(AboutMemoplannerColumn),
          matching: find.byType(DoubleText),
        )
        .evaluate();

    expect(doubleTextsInAboutColumn.length, 2);
    expect(find.text('BACD-FGAH-JKLA-NOAP'), findsOneWidget);
    expect(find.text('8/8/2023'), findsNothing);
  });
}
