import 'dart:async';
import 'dart:ui';

import 'package:logging/logging.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:seagull_analytics/analytics_events.dart';

export 'analytics_events.dart';
export 'navigation_observer.dart';
export 'trackable.dart';
export 'widgets/trackable_page_view.dart';
export 'widgets/trackable_tab_bar_view.dart';

final _log = Logger('SeagullAnalytics');

class SeagullAnalytics {
  Mixpanel? _mixpanel;
  final Map<String, dynamic> superProperties;
  final String identifier;

  SeagullAnalytics(this._mixpanel, this.superProperties, this.identifier);
  SeagullAnalytics.empty()
      : _mixpanel = null,
        superProperties = {},
        identifier = '';

  static Future<SeagullAnalytics> init({
    required MixpanelProject project,
    required String identifier,
    required Map<String, dynamic> superProperties,
  }) async {
    final mixpanel = await _init(
      project: project,
      identifier: identifier,
      superProperties: superProperties,
    );
    _log.fine(
      'initialized with identifier: $identifier '
      'and superProperties: $superProperties',
    );
    return SeagullAnalytics(mixpanel, superProperties, identifier);
  }

  static Future<Mixpanel> _init({
    required MixpanelProject project,
    required String identifier,
    required Map<String, dynamic> superProperties,
  }) async {
    _log.fine(
      'init mixpanel project ${project.name}, '
      'identifier: $identifier, '
      'and super properties: $superProperties',
    );
    final mixpanel = await Mixpanel.init(
      project.token,
      trackAutomaticEvents: true,
      superProperties: superProperties,
    );
    mixpanel.identify(identifier);
    return mixpanel;
  }

  Future<void> changeMixpanelProject(MixpanelProject project) async {
    _mixpanel = await _init(
      project: project,
      identifier: identifier,
      superProperties: superProperties,
    );
  }

  void reset() {
    _mixpanel?.reset();
    _mixpanel?.registerSuperProperties(superProperties);
    _log.info('reset');
  }

  void setBackend(String environment) {
    setSuperProperties(
      {AnalyticsProperties.environment: environment},
      persistOnLogout: true,
    );
    _log.fine('set backend $environment');
  }

  void setLocale(Locale locale) {
    final language = locale.languageCode;
    final superProp = {
      AnalyticsProperties.locale: '$locale',
      AnalyticsProperties.language: language,
    };
    setSuperProperties(superProp, persistOnLogout: true);
    _log.fine('locale set $superProp');
  }

  void setSuperProperties(
    Map<String, String> properties, {
    bool persistOnLogout = false,
  }) {
    if (persistOnLogout) {
      superProperties.addAll(properties);
    }
    _mixpanel?.registerSuperProperties(properties);
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
    _log
      ..finer('tracking $eventName')
      ..finer('$eventName props: $properties');
    _mixpanel?.track(eventName, properties: properties);
  }
}

enum MixpanelProject {
  sandbox(token: 'ec055a51cad7dbc9fa91ff5ac90cd09f'),
  memoProd(token: '814838948a0be3497bcce0421334edb2');

  const MixpanelProject({required this.token});
  final String token;
}

enum NavigationAction {
  opened,
  closed,
  viewed,
}
