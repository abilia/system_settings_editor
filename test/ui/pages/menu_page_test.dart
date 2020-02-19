import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/pages/menu_page.dart';

import '../../mocks.dart';

void main() {
  AuthenticationBloc mockedActivitiesBloc = MockAuthenticationBloc();

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => mockedActivitiesBloc),
          BlocProvider<ActivitiesBloc>(
              create: (context) => MockActivitiesBloc()),
        ], child: widget),
      );
  testWidgets('Menu page shows', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
    await tester.pumpAndSettle();
    expect(find.byType(LogoutButton), findsOneWidget);
  });
}
