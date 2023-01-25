import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/ui/all.dart';

class AnalyticNavigationObserver extends RouteObserver<PageRoute<dynamic>> {
  final SeagullAnalytics analytics;
  final _log = Logger('RouteLogger');

  AnalyticNavigationObserver(this.analytics);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final settings = route.settings;
    if (settings is TrackableRouteSettings) {
      analytics.track(settings.analyticName, properties: settings.properties);
    }
    _log.fine('didPush $route');
    _log.finest('didPush previousRoute $previousRoute');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log.fine('didReplace $newRoute');
    _log.finest('didReplace oldRoute $oldRoute');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log.fine('didPop $route');
    _log.finest('didPop previousRoute $previousRoute');
  }
}
