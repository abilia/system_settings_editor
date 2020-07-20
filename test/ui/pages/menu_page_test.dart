import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/pages/all.dart';

import '../../mocks.dart';

void main() {
  final mockSettingsDb = MockSettingsDb();
  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        builder: (context, child) => MultiBlocProvider(providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => MockAuthenticationBloc()),
          BlocProvider<ActivitiesBloc>(
              create: (context) => MockActivitiesBloc()),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(settingsDb: mockSettingsDb),
          ),
        ], child: child),
        home: widget,
      );

  testWidgets('Menu page shows', (WidgetTester tester) async {
    when(mockSettingsDb.getDotsInTimepillar()).thenReturn(true);
    await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
    await tester.pumpAndSettle();
    expect(find.byType(LogoutPickField), findsOneWidget);
    await tester.tap(find.byType(LogoutPickField));
    await tester.pumpAndSettle();
    expect(find.byType(LogoutButton), findsOneWidget);
    expect(find.byType(ProfilePictureNameAndEmail), findsOneWidget);
  });
}
