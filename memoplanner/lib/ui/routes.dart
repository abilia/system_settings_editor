import 'package:memoplanner/ui/all.dart';

mixin PersistentRoute {}

class AlarmRoute<T> extends MaterialPageRoute<T> with PersistentRoute {
  AlarmRoute({
    required WidgetBuilder builder,
    bool fullscreenDialog = false,
  }) : super(builder: builder, fullscreenDialog: fullscreenDialog);
}

class PersistentMaterialPageRoute<T> extends MaterialPageRoute<T>
    with PersistentRoute {
  PersistentMaterialPageRoute({
    required super.builder,
    super.settings,
  });
}

class PersistentPageRouteBuilder<T> extends PageRouteBuilder<T>
    with PersistentRoute {
  PersistentPageRouteBuilder({
    required super.pageBuilder,
    super.settings,
    super.transitionsBuilder,
  });
}

class PersistentDialogRoute<T> extends DialogRoute<T> with PersistentRoute {
  PersistentDialogRoute({
    required super.context,
    required super.builder,
    super.themes,
    super.barrierColor = Colors.black54,
    super.barrierDismissible,
    super.barrierLabel,
    super.useSafeArea = true,
    super.settings,
    super.anchorPoint,
  });
}
