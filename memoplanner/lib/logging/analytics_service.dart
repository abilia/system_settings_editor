import 'dart:async';

import 'package:memoplanner/ui/all.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'package:memoplanner/models/all.dart';

class SeagullAnalytics {
  final Mixpanel? mixpanel;
  final Map<String, dynamic> superProperties;
  SeagullAnalytics._(this.mixpanel, this.superProperties);
  SeagullAnalytics.empty()
      : mixpanel = null,
        superProperties = {};

  static Future<SeagullAnalytics> init(
    String clientId,
    String? environment,
  ) async {
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
    return SeagullAnalytics._(mixpanel, superProperties);
  }

  void setUser(User user) {
    mixpanel?.identify('${user.id}');
    mixpanel?.registerSuperProperties({
      'user_type': user.type,
      'user_language': user.language,
    });
  }

  void reset() {
    mixpanel?.reset();
    mixpanel?.registerSuperProperties(superProperties);
  }

  static const environmentKey = 'environment';
  void setBackend(String environment) {
    superProperties[environmentKey] = environment;
    mixpanel?.registerSuperProperties({environmentKey: environment});
  }

  void track(String eventName, {Map<String, dynamic>? properties}) =>
      mixpanel?.track(eventName, properties: properties);

}
