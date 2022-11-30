import 'package:memoplanner/ui/all.dart';

class BottomNavigation extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget? forwardNavigationWidget;
  final Color color;
  final bool useVerticalSafeArea;

  const BottomNavigation({
    required this.backNavigationWidget,
    this.forwardNavigationWidget,
    this.color = ViewDialog.dark,
    this.useVerticalSafeArea = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final forwardNavigationWidget = this.forwardNavigationWidget;
    return _BottomNavigationContainer(
      useVerticalSafeArea: useVerticalSafeArea,
      color: color,
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

class _BottomNavigationContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final bool useVerticalSafeArea;

  const _BottomNavigationContainer({
    required this.child,
    required this.color,
    this.useVerticalSafeArea = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
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
