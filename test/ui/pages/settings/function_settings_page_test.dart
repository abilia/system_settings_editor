import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../mocks.dart';

void main() {
  testWidgets('function settings page ...', (tester) async {
    await tester.pumpApp(FunctionSettingsPage());
    expect(find.byType(FunctionSettingsPage), findsOneWidget);
    expect(find.byType(OkButton), findsOneWidget);
    expect(find.byType(CancelButton), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpApp(Widget widget) => pumpWidget(
        MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: [Translator.delegate],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          home: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => SettingsBloc(
                  settingsDb: MockSettingsDb(),
                ),
              ),
            ],
            child: widget,
          ),
        ),
      ).then((_) => pumpAndSettle());
}
