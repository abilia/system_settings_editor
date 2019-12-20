import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class MockUrlLauncher extends Mock implements UrlLauncherPlatform {}

void main() {
  String text = 'text';
  String url = 'https://myabilia.com/';
  group('web link test', () {
    testWidgets('show Weblink text', (WidgetTester tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: WebLink(
          text: text,
          urlString: url,
        ),
      ));
      expect(find.text(text), findsOneWidget);
    });
  });
}
