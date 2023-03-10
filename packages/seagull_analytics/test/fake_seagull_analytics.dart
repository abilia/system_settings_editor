import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

class FakeSeagullAnalytics extends Fake implements SeagullAnalytics {
  @override
  void identifyAndRegisterSuperProperties(
      {required String identifier,
      required Map<String, dynamic> superProperties}) {}

  @override
  void reset() {}

  @override
  void setBackend(String environment) {}

  @override
  void setLocale(Locale locale) {}

  @override
  Map<String, dynamic> get superProperties => {};

  @override
  void trackEvent(String eventName, {Map<String, dynamic>? properties}) {}

  @override
  void trackNavigation(
      {required String page,
      required NavigationAction action,
      Map<String, dynamic>? properties}) {}
}
