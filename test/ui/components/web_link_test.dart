import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/ui/components.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class MockUrlLauncher extends Mock implements UrlLauncherPlatform {}

void main() {
  MockUrlLauncher mock;
  String text = 'text';
  String url = 'https://myabilia.com/';
  group('web link test', () {
    setUp(() {
      mock = MockUrlLauncher();
      when(mock.isMock).thenReturn(true);
      UrlLauncherPlatform.instance = mock;
    });

    testWidgets('show Weblink text', (WidgetTester tester) async {
      await tester.pumpWidget(Directionality( textDirection: TextDirection.ltr,
              child: WebLink(text: text, urlString: url,
        ),
      ));
      expect(find.text(text), findsOneWidget);
    });

    testWidgets('tap Weblink opens link', (WidgetTester tester) async {
      await tester.pumpWidget(Directionality( textDirection: TextDirection.ltr,
              child: WebLink(text: text, urlString: url,
        ),
      ));
      await tester.tap(find.text(text));

      expect(
        verify(mock.launch(
          captureAny,
          useSafariVC: captureAnyNamed('useSafariVC'),
          useWebView: captureAnyNamed('useWebView'),
          enableJavaScript: captureAnyNamed('enableJavaScript'),
          enableDomStorage: captureAnyNamed('enableDomStorage'),
          universalLinksOnly: captureAnyNamed('universalLinksOnly'),
          headers: captureAnyNamed('headers'),
        )).captured,
        <dynamic>[
          url,
          true,
          false,
          false,
          false,
          false,
          <String, String>{},
        ],
      );
    });
  });
}
