import 'package:memoplanner/ui/all.dart';

mixin PersistentPageRoute<T> on PageRoute<T> {}

class AlarmRoute<T> extends MaterialPageRoute<T> with PersistentPageRoute<T> {
  AlarmRoute({
    required WidgetBuilder builder,
    bool fullscreenDialog = false,
  }) : super(builder: builder, fullscreenDialog: fullscreenDialog);
}

class PersistentMaterialPageRoute<T> extends MaterialPageRoute<T>
    with PersistentPageRoute {
  PersistentMaterialPageRoute({
    required super.builder,
    super.settings,
  });
}

class PersistentPageRouteBuilder<T> extends PageRouteBuilder<T>
    with PersistentPageRoute {
  PersistentPageRouteBuilder({
    required super.pageBuilder,
    super.settings,
    super.transitionsBuilder,
  });
}
