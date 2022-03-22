import 'package:seagull/ui/all.dart';

class BottomNavigation extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget? forwardNavigationWidget;
  final bool useSafeArea;

  const BottomNavigation({
    Key? key,
    required this.backNavigationWidget,
    this.forwardNavigationWidget,
    this.useSafeArea = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final forwardNavigationWidget = this.forwardNavigationWidget;
    return _BottomNavigation(
      useSafeArea: useSafeArea,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (forwardNavigationWidget != null) ...[
            Expanded(child: backNavigationWidget),
            SizedBox(width: layout.formPadding.horizontalItemDistance),
            Expanded(child: forwardNavigationWidget),
          ] else
            Center(child: backNavigationWidget),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final bool useSafeArea;
  const _BottomNavigation({
    Key? key,
    required this.child,
    this.useSafeArea = true,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = Container(
      color: AbiliaColors.black80,
      height: layout.navigationBar.height,
      child: Padding(
        padding: layout.templates.bottomNavigation,
        child: child,
      ),
    );

    if (useSafeArea) {
      return Container(
        color: AbiliaColors.black80,
        child: SafeArea(
          child: bottom,
        ),
      );
    }
    return bottom;
  }
}
