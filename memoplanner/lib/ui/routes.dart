import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/ui/all.dart';

extension TypeRoute on Type {
  TrackableRouteSettings routeSetting({Map<String, dynamic>? properties}) =>
      TrackableRouteSettings(
        name: toString(),
        properties: properties,
      );
}

class TrackableRouteSettings extends RouteSettings implements Trackable {
  @override
  String get eventName => 'Nav $name';
  @override
  final Map<String, dynamic>? properties;
  const TrackableRouteSettings({required super.name, this.properties});
}

mixin PersistentRoute {}
mixin ActivityRootRoute {}

class AlarmRoute<T> extends MaterialPageRoute<T> with PersistentRoute {
  AlarmRoute({
    required super.builder,
    required super.settings,
    super.fullscreenDialog,
  });
}

class PersistentMaterialPageRoute<T> extends MaterialPageRoute<T>
    with PersistentRoute {
  PersistentMaterialPageRoute({
    required super.builder,
    required super.settings,
  });
}

class PersistentPageRouteBuilder<T> extends PageRouteBuilder<T>
    with PersistentRoute {
  PersistentPageRouteBuilder({
    required super.pageBuilder,
    required super.settings,
    super.transitionsBuilder,
  });
}

class ActivityRootPageRouteBuilder<T> extends PageRouteBuilder<T>
    with ActivityRootRoute {
  ActivityRootPageRouteBuilder({
    required super.pageBuilder,
    required super.settings,
  });
}

class PersistentDialogRoute<T> extends DialogRoute<T> with PersistentRoute {
  PersistentDialogRoute({
    required super.context,
    required super.builder,
    required super.settings,
    super.themes,
    super.barrierColor = Colors.black54,
    super.barrierDismissible,
    super.barrierLabel,
    super.useSafeArea = true,
    super.anchorPoint,
  });
}
