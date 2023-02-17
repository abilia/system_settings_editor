import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

class AnalyticNavigationObserver extends RouteObserver<PageRoute> {
  final SeagullAnalytics analytics;
  final _log = Logger('RouteLogger');

  AnalyticNavigationObserver(this.analytics);

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route, NavigationAction.opened);
    _log.fine('didPush $route');
    _log.finest('didPush previousRoute $previousRoute');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log.fine('didReplace $newRoute');
    _log.finest('didReplace oldRoute $oldRoute');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _trackRoute(route, NavigationAction.closed);
    _log.fine('didPop $route');
    _log.finest('didPop previousRoute $previousRoute');
  }

  void _trackRoute(Route route, NavigationAction navigationAction) {
    final settings = route.settings;
    if (settings is TrackableRouteSettings && settings.name != null) {
      analytics.trackNavigation(
        page: settings.name.toString(),
        properties: settings.properties,
        action: navigationAction,
      );
    }
  }
}
