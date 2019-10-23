import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/main.dart';
import 'package:seagull/ui/pages/login_page.dart';
import 'package:seagull/ui/pages/splash_page.dart';

void main() {
  testWidgets('Application starts', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.text('Splash Screen'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is SplashPage), findsOneWidget);    
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Password'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is LoginPage), findsOneWidget);
  });
}
