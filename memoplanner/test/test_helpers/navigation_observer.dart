import 'package:flutter/widgets.dart';

class NavObserver extends NavigatorObserver {
  final routesPoped = <Route>[];
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    routesPoped.add(route);
  }
}
