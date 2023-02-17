import 'dart:async';
import 'dart:ui';

import 'package:logging/logging.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'analytics_events.dart';

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

  static Future<SeagullAnalytics> init(
    String token, {
    required Map<String, dynamic> superProperties,
  }) async {
    final mixpanel = await Mixpanel.init(
      token,
      trackAutomaticEvents: true,
      superProperties: superProperties,
    );
    _log.fine('initialized with superProperties: $superProperties');
    return SeagullAnalytics(mixpanel, superProperties);
  }

  void identifyAndRegisterSuperProperties({
    required String identifier,
    required Map<String, dynamic> superProperties,
  }) {
    mixpanel?.identify(identifier);
    mixpanel?.registerSuperProperties(superProperties);
    _log.fine('user superProperties: $superProperties');
    _log.fine('user set: $identifier');
  }

  void reset() {
    mixpanel?.reset();
    mixpanel?.registerSuperProperties(superProperties);
    _log.info('reset');
  }

  void setBackend(String environment) {
    superProperties[AnalyticsProperties.environment] = environment;
    mixpanel?.registerSuperProperties(
      {AnalyticsProperties.environment: environment},
    );
    _log.fine('set backend $environment');
  }

  void setLocale(Locale locale) {
    final language = locale.languageCode;
    superProperties[AnalyticsProperties.locale] = '$locale';
    superProperties[AnalyticsProperties.language] = language;
    final superProp = {
      AnalyticsProperties.locale: '$locale',
      AnalyticsProperties.language: language,
    };
    mixpanel?.registerSuperProperties(superProp);
    _log.fine('locale set $superProp');
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
