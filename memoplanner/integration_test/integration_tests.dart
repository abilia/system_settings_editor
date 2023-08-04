import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memoplanner/main.dart' as app;
import 'package:memoplanner/ui/all.dart';

void main() {
  const testId = String.fromEnvironment('testId');
  const backend = 'Whale';

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    sleep(const Duration(seconds: 2));
    await GetIt.I.reset();
  });

  setUp(() async {
    app.main();
  });

  testWidgets('Login with wrong password', (WidgetTester tester) async {
    await tester.login('IGT$testId', backend, password: 'wrongpassword');
    expect(find.byType(ErrorMessage), findsOneWidget);
  });

  testWidgets('Login with no license', (WidgetTester tester) async {
    await tester.login(
      'IGT$testId',
      backend,
    );
    expect(find.byType(LicenseErrorDialog), findsOneWidget);
  });

  testWidgets('Create activity with note SGC-502', (WidgetTester tester) async {
    await tester.login(
      'IGTWL$testId',
      backend,
    );
    if (Platform.isAndroid) {
      await tester.pressCancelButton();
    }

    const note =
        'Lorem Ipsum är en utfyllnadstext från tryck- och förlagsindustrin. Lorem ipsum har varit standard ända sedan 1500-talet, när en okänd boksättare tog att antal bokstäver och blandade dem för att göra ett provexemplar av en bok. Lorem ipsum har inte bara överlevt fem århundraden, utan även övergången till elektronisk typografi utan större förändringar. Det blev allmänt känt på 1960-talet i samband med lanseringen av Letraset-ark med avsnitt av Lorem Ipsum, och senare med mjukvaror som Aldus PageMaker.';
    await tester.createActivityWithNote(note);

    final center = tester.getCenter(find.byType(CalendarPage));
    await tester.dragFrom(center, Offset(center.dx, center.dy - 100));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ActivityCard));
    await tester.pumpAndSettle();
    expect(find.text(note), findsOneWidget);
    await tester.tap(find.byKey(TestKey.activityBackButton));
    await tester.pumpAndSettle();

    const newNote = 'Ny information';
    await tester.editNote(newNote);

    await tester.tap(find.byType(ActivityCard));
    await tester.pumpAndSettle();
    expect(find.text(newNote), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> selectBackend(String env) async {
    await pumpAndSettle();
    await longPress(find.byType(MEMOplannerLogoHiddenBackendSwitch));
    await pumpAndSettle();
    await tap(find.text(env));
    await pumpAndSettle();
    await tap(find.byType(OkButton));
    await pumpAndSettle();
  }

  Future<void> editNote(String extraNote) async {
    await tap(find.byType(ActivityCard));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.edit));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.attachment));
    await pumpAndSettle();
    await tap(find.byType(NoteBlock));
    await pumpAndSettle();
    await showKeyboard(find.byKey(TestKey.input));
    await pumpAndSettle();
    await enterText(find.byKey(TestKey.input), extraNote);
    await pumpAndSettle();
    await tap(find.byType(OkButton));
    await pumpAndSettle();
    await tap(find.byType(NextWizardStepButton));
    await pumpAndSettle();
    await tap(find.byKey(TestKey.activityBackButton));
    await pumpAndSettle();
  }

  Future<void> createActivityWithNote(String note) async {
    await tap(find.byType(AddButton));
    await pumpAndSettle();

    await tap(find.byType(NextButton));
    await pumpAndSettle();

    await tap(find.byType(NameInput));
    await pumpAndSettle();

    await showKeyboard(find.byKey(TestKey.input));
    await pumpAndSettle();
    await enterText(find.byKey(TestKey.input), 'Activity with note');
    await tap(find.byType(OkButton));
    await pumpAndSettle();

    await tap(find.byType(TimeIntervalPicker));
    await pumpAndSettle();

    await tap(find.byKey(TestKey.startTimeInput));
    await pumpAndSettle();
    await showKeyboard(find.byKey(TestKey.startTimeInput));
    await pumpAndSettle();
    await enterText(find.byKey(TestKey.startTimeInput), '1000');
    await tap(find.byType(OkButton));
    await pumpAndSettle();

    await tap(find.byIcon(AbiliaIcons.attachment));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.information));
    await pumpAndSettle();
    await tap(find.byType(OkButton));
    await pumpAndSettle();
    await tap(find.byType(NoteBlock));
    await pumpAndSettle();

    await showKeyboard(find.byKey(TestKey.input));
    await pumpAndSettle();
    await enterText(find.byKey(TestKey.input), note);
    await pumpAndSettle();
    await tap(find.byType(OkButton));
    await pumpAndSettle();
    await tap(find.byType(NextWizardStepButton));
    await pumpAndSettle();
  }

  Future<void> login(String userName, String backend,
      {String password = 'password'}) async {
    await selectBackend(backend);
    await tap(find.byType(UsernameInput));
    await pumpAndSettle();
    await showKeyboard(find.byKey(TestKey.input));
    await pumpAndSettle();
    await enterText(find.byKey(TestKey.input), userName);
    await pumpAndSettle();
    await tap(find.byType(OkButton));
    await pumpAndSettle();

    await tap(find.byType(PasswordInput));
    await pumpAndSettle();
    await showKeyboard(find.byKey(TestKey.input));
    await pumpAndSettle();
    await enterText(find.byKey(TestKey.input), password);
    await pumpAndSettle();
    await tap(find.byType(OkButton));
    await pumpAndSettle();

    await tap(find.byType(LoginButton));
    await pumpAndSettle();
  }

  Future<void> pressCancelButton() async {
    await tap(find.byType(CancelButton));
    await pumpAndSettle();
  }
}
