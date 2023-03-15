import 'dart:async';
import 'dart:ui';

import 'package:logging/logging.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'package:seagull_analytics/analytics_events.dart';

export 'widgets/trackable_page_view.dart';
export 'widgets/trackable_tab_bar_view.dart';
export 'navigation_observer.dart';
export 'trackable.dart';
export 'analytics_events.dart';

final _log = Logger('SeagullAnalytics');

class SeagullAnalytics {
  final Mixpanel? mixpanel;
  final Map<String, dynamic> superProperties;

  const SeagullAnalytics(this.mixpanel, this.superProperties);
  SeagullAnalytics.empty()
      : mixpanel = null,
        superProperties = {};

  static Future<SeagullAnalytics> init({
    required String token,
    required String identifier,
    required Map<String, dynamic> superProperties,
  }) async {
    final mixpanel = await Mixpanel.init(
      token,
      trackAutomaticEvents: true,
      superProperties: superProperties,
    );
    mixpanel.identify(identifier);
    _log.fine(
      'initialized with identifier: $identifier '
      'and superProperties: $superProperties',
    );
    return SeagullAnalytics(mixpanel, superProperties);
  }

  void reset() {
    mixpanel?.reset();
    mixpanel?.registerSuperProperties(superProperties);
    _log.info('reset');
  }

  void setBackend(String environment) {
    setSuperProperties(
      {AnalyticsProperties.environment: environment},
      presistOnLogout: true,
    );
    _log.fine('set backend $environment');
  }

  void setLocale(Locale locale) {
    final language = locale.languageCode;
    final superProp = {
      AnalyticsProperties.locale: '$locale',
      AnalyticsProperties.language: language,
    };
    setSuperProperties(superProp, presistOnLogout: true);
    _log.fine('locale set $superProp');
  }

  void setSuperProperties(
    Map<String, String> properties, {
    bool presistOnLogout = false,
  }) {
    if (presistOnLogout) {
      superProperties.addAll(properties);
    }
    mixpanel?.registerSuperProperties(properties);
  }

  void trackNavigation({
    required String page,
    required NavigationAction action,
    Map<String, dynamic>? properties,
  }) {
    properties ??= {};
    properties[AnalyticsProperties.page] = page;
    properties[AnalyticsProperties.action] = action.name;
    trackEvent(AnalyticsEvents.navigation, properties: properties);
  }

  void trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) {
    _log.finer('tracking $eventName');
    _log.finer('$eventName props: $properties');
    mixpanel?.track(eventName, properties: properties);
  }
}

enum NavigationAction {
  opened,
  closed,
  viewed,
}
