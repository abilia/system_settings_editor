import 'package:seagull/ui/all.dart';

class BottomNavigation extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget? forwardNavigationWidget;
  final bool useVerticalSafeArea;

  const BottomNavigation({
    required this.backNavigationWidget,
    this.forwardNavigationWidget,
    this.useVerticalSafeArea = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final forwardNavigationWidget = this.forwardNavigationWidget;
    return _BottomNavigation(
      useVerticalSafeArea: useVerticalSafeArea,
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
  final bool useVerticalSafeArea;
  const _BottomNavigation({
    required this.child,
    this.useVerticalSafeArea = true,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AbiliaColors.black80,
      child: SafeArea(
        top: useVerticalSafeArea,
        bottom: useVerticalSafeArea,
        child: SizedBox(
          height: layout.navigationBar.height,
          child: Padding(
            padding: layout.templates.bottomNavigation,
            child: child,
          ),
        ),
      ),
    );
  }
}
