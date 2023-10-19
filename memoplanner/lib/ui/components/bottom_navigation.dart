import 'package:memoplanner/ui/all.dart';

class BottomNavigation extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget? forwardNavigationWidget;
  final Color color;
  final bool useVerticalSafeArea;
  final bool verticalButtons;

  const BottomNavigation({
    required this.backNavigationWidget,
    this.forwardNavigationWidget,
    this.color = ViewDialog.dark,
    this.useVerticalSafeArea = true,
    this.verticalButtons = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: SafeArea(
        top: useVerticalSafeArea,
        bottom: useVerticalSafeArea,
        child: SizedBox(
          height: verticalButtons
              ? layout.navigationBar.doubleHeight
              : layout.navigationBar.height,
          child: Padding(
            padding: layout.navigationBar.padding,
            child: verticalButtons
                ? _VerticalBottomNavigationContainer(
                    backNavigationWidget: backNavigationWidget,
                    forwardNavigationWidget: forwardNavigationWidget,
                  )
                : _HorizontalBottomNavigationContainer(
                    backNavigationWidget: backNavigationWidget,
                    forwardNavigationWidget: forwardNavigationWidget,
                  ),
          ),
        ),
      ),
    );
  }
}

class _HorizontalBottomNavigationContainer extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget? forwardNavigationWidget;

  const _HorizontalBottomNavigationContainer(
      {required this.backNavigationWidget,
      required this.forwardNavigationWidget});

  @override
  Widget build(BuildContext context) {
    final forwardNavigationWidget = this.forwardNavigationWidget;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (forwardNavigationWidget != null) ...[
          Expanded(child: backNavigationWidget),
          SizedBox(width: layout.formPadding.horizontalItemDistance),
          Expanded(child: forwardNavigationWidget),
        ] else
          Center(child: backNavigationWidget),
      ],
    );
  }
}

class _VerticalBottomNavigationContainer extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget? forwardNavigationWidget;

  const _VerticalBottomNavigationContainer({
    required this.backNavigationWidget,
    required this.forwardNavigationWidget,
  });

  @override
  Widget build(BuildContext context) {
    final forwardNavigationWidget = this.forwardNavigationWidget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (forwardNavigationWidget != null) ...[
          Expanded(child: forwardNavigationWidget),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          Expanded(child: backNavigationWidget),
        ] else
          Center(child: backNavigationWidget),
      ],
    );
  }
}
