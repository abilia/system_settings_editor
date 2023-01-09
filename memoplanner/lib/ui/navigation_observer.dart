import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class NavigationObserver extends RouteObserver<PageRoute<dynamic>> {
  final NavigationCubit navigationCubit;

  NavigationObserver(this.navigationCubit);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    navigationCubit.push();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    navigationCubit.replace();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    navigationCubit.pop();
  }
}
