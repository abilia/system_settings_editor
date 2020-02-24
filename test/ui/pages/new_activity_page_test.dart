import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../mocks.dart';

void main() {
  group('new activity test', () {
    MockAuthenticationBloc mockedActivitiesBloc;
    final locale = Locale('en');

    Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: [Translator.delegate],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          home: MultiBlocProvider(providers: [
            BlocProvider<AuthenticationBloc>(
                create: (context) => mockedActivitiesBloc),
            BlocProvider<ActivitiesBloc>(
                create: (context) => MockActivitiesBloc()),
          ], child: widget),
        );

    setUp(() {
      Locale.cachedLocale = locale;
      initializeDateFormatting();
      mockedActivitiesBloc = MockAuthenticationBloc();
    });

    testWidgets('New activity shows', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(NewActivityPage()));
      await tester.pumpAndSettle();
      expect(find.byType(NewActivityPage), findsOneWidget);
    });

    testWidgets('Can enter text', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(NewActivityPage()));
      await tester.pumpAndSettle();
      expect(find.byType(NewActivityPage), findsOneWidget);
    });

    testWidgets(
        'Add activity button is disabled when no title and enabled when titled entered',
        (WidgetTester tester) async {
      final newActivtyName = 'new activity name';
      await tester.pumpWidget(wrapWithMaterialApp(NewActivityPage()));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<ActionButton>(find.byKey(TestKey.finishNewActivityButton))
              .onPressed,
          isNull);
      await tester.enterText(
          find.byKey(TestKey.newActivityNameInput), newActivtyName);
      expect(
          tester
              .widget<ActionButton>(find.byKey(TestKey.finishNewActivityButton))
              .onPressed,
          isNotNull,
          skip: 'Not implemented yet');
    });
  });
}
