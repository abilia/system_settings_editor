import 'package:flutter/widgets.dart';
import 'package:memoplanner/ui/routes.dart';

extension NavExtension on NavigatorState {
  void popUntilRootOrPersistentPage() =>
      popUntil((route) => route.isFirst || route is PersistentRoute);

  void popUntilActivityRootPage() =>
      popUntil((route) => route.isFirst || route is ActivityRootRoute);
}
