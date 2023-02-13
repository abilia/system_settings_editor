import 'dart:async';
import 'dart:ui';

import 'package:logging/logging.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

export 'widgets/trackable_page_view.dart';
export 'widgets/trackable_tab_bar_view.dart';
export 'trackable.dart';
export 'fake_seagull_analytics.dart';
export 'navigation_observer.dart';

final _log = Logger('SeagullAnalytics');

class SeagullAnalytics {
  static const environmentKey = 'environment',
      localeKey = 'locale',
      languageKey = 'language';
  final Mixpanel? mixpanel;
  final Map<String, dynamic> superProperties;

  const SeagullAnalytics(this.mixpanel, this.superProperties);

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
    superProperties[environmentKey] = environment;
    mixpanel?.registerSuperProperties({environmentKey: environment});
    _log.fine('set backend $environment');
  }

  void setLocale(Locale locale) {
    final language = locale.languageCode;
    superProperties[localeKey] = '$locale';
    superProperties[languageKey] = language;
    final superProp = {
      localeKey: '$locale',
      languageKey: language,
    };
    mixpanel?.registerSuperProperties(superProp);
    _log.fine('locale set $superProp');
  }

  void trackNavigation({
    required String page,
    required NavigationAction action,
    required Map<String, dynamic> properties,
  }) {
    properties['page'] = page;
    properties['action'] = action.name;
    trackEvent('Navigation', properties: properties);
  }

  void trackEvent(
    String eventName, {
    required Map<String, dynamic> properties,
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
