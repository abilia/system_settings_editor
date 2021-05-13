import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/config.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../mocks.dart';

void main() {
  group(
    'create accpput',
    () {
      final translate = Locales.language.values.first;

      setUp(() async {
        GetItInitializer()
          ..sharedPreferences =
              await MockSharedPreferences.getInstance(loggedIn: false)
          ..ticker = Ticker(
            stream: StreamController<DateTime>().stream,
            initialTime: DateTime(2021, 05, 13, 11, 29),
          )
          ..client = Fakes.client()
          ..init();
      });

      tearDown(GetIt.I.reset);

      testWidgets('Go to create account and back', (tester) async {
        await tester.pumpApp();
        expect(find.byType(CreateAccountView), findsOneWidget);
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();
        expect(find.byType(CreateAccountPage), findsOneWidget);
        await tester.tap(find.byType(BackToLoginButton));
        await tester.pumpAndSettle();
        expect(find.byType(LoginPage), findsOneWidget);
      }, tags: Flavor.mp.tag);

      testWidgets('Open terms of use', (tester) async {
        await tester.pumpApp();
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();
        expect(find.tapTextSpan(translate.termsOfUse), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(WebViewDialog), findsOneWidget);
        final openedUrl =
            tester.widget<WebView>(find.byType(WebView)).initialUrl;
        expect(openedUrl, CreateAccountPage.termsOfUseUrl);
      }, tags: Flavor.mp.tag);

      testWidgets('Open privacuy policy', (tester) async {
        await tester.pumpApp();
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();
        expect(find.tapTextSpan(translate.privacyPolicy), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(WebViewDialog), findsOneWidget);
        final openedUrl =
            tester.widget<WebView>(find.byType(WebView)).initialUrl;
        expect(openedUrl, CreateAccountPage.privacyPolicyUrl);
      }, tags: Flavor.mp.tag);
    },
    skip: !Config.isMP,
  );
}
