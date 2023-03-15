import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull_analytics/seagull_analytics.dart';
import 'package:seagull_fakes/all.dart';

void main() {
  testWidgets(
      'When both getPage and children is defined, throw an assertion error',
      (WidgetTester tester) async {
    runZonedGuarded(() {
      tester.pumpWidget(
        TrackablePageView(
          controller: PageController(),
          analytics: FakeSeagullAnalytics(),
          getPage: (context) => Container(),
          children: [
            Container(),
          ],
        ),
      );
    }, (e, __) {
      expect(e, isInstanceOf<AssertionError>());
    });
  });

  testWidgets(
      'When none of getPage and children is defined, throw an assertion error',
      (WidgetTester tester) async {
    runZonedGuarded(() {
      tester.pumpWidget(
        TrackablePageView(
          controller: PageController(),
          analytics: FakeSeagullAnalytics(),
        ),
      );
    }, (e, __) {
      expect(e, isInstanceOf<AssertionError>());
    });
  });
}
