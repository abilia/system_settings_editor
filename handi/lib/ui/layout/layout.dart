import 'package:handi/ui/layout/buttons.dart';

Layout getLayout() => const Layout();

class Layout {
  final ActionButtonLayout actionButtonLayout;

  const Layout({
    this.actionButtonLayout = const ActionButtonLayout(),
  });
}
