import 'dart:async';

import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'package:memoplanner/models/all.dart';

final _log = Logger('SeagullAnalytics');

class SeagullAnalytics {
  static const environmentKey = 'environment',
      localeKey = 'locale',
      languageKey = 'language';
  final Mixpanel? mixpanel;
  final Map<String, dynamic> superProperties;
  SeagullAnalytics._(this.mixpanel, this.superProperties);
  SeagullAnalytics.empty()
      : mixpanel = null,
        superProperties = {};

  static Future<SeagullAnalytics> init({
    required String clientId,
    required String environment,
  }) async {
    final superProperties = {
      'flavor': Config.flavor.name,
      'release': Config.release,
      'clientId': clientId,
      environmentKey: environment,
    };
    final mixpanel = await Mixpanel.init(
      '814838948a0be3497bcce0421334edb2',
      trackAutomaticEvents: true,
      superProperties: superProperties,
    );
    _log.fine('initiliased with superProperties: $superProperties');
    return SeagullAnalytics._(mixpanel, superProperties);
  }

  void setUser(User user) {
    mixpanel?.identify('${user.id}');
    final superPros = {
      'user_type': user.type,
      'user_language': user.language,
    };
    mixpanel?.registerSuperProperties(superPros);
    _log.fine('user superProperties: $superPros');
    _log.fine('user set: ${user.id}');
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

  void track(String eventName, {Map<String, dynamic>? properties}) {
    _log.finer('tracking $eventName');
    if (properties != null) _log.finer('$eventName props: $properties');
    mixpanel?.track(eventName, properties: properties);
  }
}
