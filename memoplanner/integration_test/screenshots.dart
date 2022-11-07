// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:seagull/main.dart' as app;
import 'package:seagull/ui/all.dart';

void main() async {
  const userId = 'screenshot';
  const backend = 'STAGING';

  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    print('teardown');
    await GetIt.I.reset();
  });

  testWidgets('Production guide', (WidgetTester tester) async {
    app.main();
    await tester.pumpUntilFound(find.byType(ProductionGuidePage));
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('production_guide');
  });

  testWidgets('Welcome', (WidgetTester tester) async {
    app.main();
    await tester.pumpUntilFound(find.byType(ProductionGuidePage));
    await tester.tap(find.byKey(TestKey.skipProductionGuide));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('welcome');
  });

  testWidgets('Welcome 2', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    final productionGuidePage =
        tester.any(find.byKey(TestKey.skipProductionGuide));
    if (productionGuidePage) {
      await tester.tap(find.byKey(TestKey.skipProductionGuide));
      await tester.pumpAndSettle();
      print('Its a productionguidepage');
    }
    await tester.pumpUntilFound(find.byKey(TestKey.startWelcomGuide));
    final welcomePage = tester.any(find.byKey(TestKey.startWelcomGuide));
    if (welcomePage) {
      await tester.tap(find.byKey(TestKey.startWelcomGuide));
      await tester.pumpAndSettle();
      print('In welcome');
    }
    print('Got this far!');
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('welcome2');
  });

  testWidgets('Welcome 3', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    final productionGuidePage =
        tester.any(find.byKey(TestKey.skipProductionGuide));
    if (productionGuidePage) {
      await tester.tap(find.byKey(TestKey.skipProductionGuide));
      await tester.pumpAndSettle();
    }
    await tester.pumpUntilFound(find.byKey(TestKey.startWelcomGuide));
    final welcomePage = tester.any(find.byKey(TestKey.startWelcomGuide));
    if (welcomePage) {
      await tester.tap(find.byKey(TestKey.startWelcomGuide));
      await tester.pumpAndSettle();
    }
    final next = tester.any(find.byKey(TestKey.nextWelcomeGuide));
    if (next) {
      await tester.tap(find.byKey(TestKey.nextWelcomeGuide));
      await tester.pumpAndSettle();
    }
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('welcome3');
  });

  testWidgets('Login', (WidgetTester tester) async {
    app.main();
    await tester.goToLogin();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('login');
  });

  testWidgets('Timepillar', (WidgetTester tester) async {
    app.main();
    await tester.pumpUntilFound(find.byType(LoginPage));
    await tester.login(userId, backend);
    await tester.pumpUntilFound(find.byType(ActivityCard));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('timepillar');
  });

  testWidgets('Agenda', (WidgetTester tester) async {
    app.main();
    await tester.pumpUntilFound(find.byType(CalendarPage));
    await tester.pumpAndSettle();

    // Switch to Agenda
    await tester.tap(find.byType(EyeButtonDay));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.calendarList));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('agenda');
  });

  testWidgets('Two timepillar', (WidgetTester tester) async {
    app.main();
    await tester.pumpUntilFound(find.byType(CalendarPage));
    await tester.pumpAndSettle();

    // Switch to two timepillars
    await tester.tap(find.byType(EyeButtonDay));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.twoTimelines));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('twotimepillar');
  });

  testWidgets('Create activity', (WidgetTester tester) async {
    app.main();
    await tester.pumpUntilFound(find.byType(CalendarPage));
    await tester.pumpAndSettle();

    // Move back to one timepillar
    await tester.tap(find.byType(EyeButtonDay));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.timeline));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(AbiliaIcons.plus));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.basicActivity));
    await tester.pumpAndSettle();

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('createactivity');
  });

  testWidgets('Create timer', (WidgetTester tester) async {
    app.main();
    await tester.pumpUntilFound(find.byType(CalendarPage));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New timer'));
    await tester.pumpAndSettle();

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('createtimer');
  });

  testWidgets('Timer', (WidgetTester tester) async {
    app.main();
    await tester.pumpUntilFound(find.byType(CalendarPage));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(AbiliaIcons.stopWatch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New timer'));
    await tester.pumpAndSettle();

    await tester.addText('Shower', NameInput);

    await tester.tap(find.byType(PickField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(StartButton));
    await tester.pumpAndSettle();

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('timer');
  });
}

Future<void> pumpForSeconds(WidgetTester tester, int seconds) async {
  bool timerDone = false;
  Timer(Duration(seconds: seconds), () => timerDone = true);
  while (timerDone != true) {
    await tester.pump();
  }
}

extension on WidgetTester {
  Future<void> goToLogin() async {
    await pumpAndSettle();
    final productionGuidePage = any(find.byKey(TestKey.skipProductionGuide));
    if (productionGuidePage) {
      await tap(find.byKey(TestKey.skipProductionGuide));
      await pumpAndSettle();
      print('Its a productionguidepage');
    }
    await pumpUntilFound(find.byKey(TestKey.startWelcomGuide));
    final welcomePage = any(find.byKey(TestKey.startWelcomGuide));
    if (welcomePage) {
      await tap(find.byKey(TestKey.startWelcomGuide));
      await pumpAndSettle();
      print('In welcome');
    }
    final next = any(find.byKey(TestKey.nextWelcomeGuide));
    if (next) {
      await tap(find.byKey(TestKey.nextWelcomeGuide));
      await pumpAndSettle();
      print('In next');
    }
    final finish = any(find.byKey(TestKey.finishWelcomeGuide));
    if (finish) {
      await tap(find.byKey(TestKey.finishWelcomeGuide));
      await pumpAndSettle();
      print('In finish');
    }
  }

  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    bool timerDone = false;
    final timer = Timer(timeout, () {
      timerDone = true;
    });
    while (timerDone != true) {
      await pump();
      final found = any(finder);
      if (found) {
        timerDone = true;
      }
    }
    print('Cancel');
    timer.cancel();
  }

  Future<void> selectBackend(String env) async {
    await pumpAndSettle();
    await longPress(find.byType(MEMOplannerLogoWithLoginProgress));
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
    await tap(find.byKey(TestKey.infoItemNoteRadio));
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

  Future<void> addText(String text, Type input) async {
    await tap(find.byType(input));
    await pumpAndSettle();
    await showKeyboard(find.byKey(TestKey.input));
    await pumpAndSettle();
    await enterText(find.byKey(TestKey.input), text);
    await pumpAndSettle();
    await tap(find.byType(OkButton));
    await pumpAndSettle();
  }

  Future<void> login(String userName, String backend,
      {String password = 'passwordpassword'}) async {
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
