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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
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
                  ? _VerticalBottomNavigationButtons(
                      backNavigationWidget: backNavigationWidget,
                      forwardNavigationWidget: forwardNavigationWidget,
                    )
                  : _BottonNavigationButtons(
                      backNavigationWidget: backNavigationWidget,
                      forwardNavigationWidget: forwardNavigationWidget),
            ),
          ),
        ),
      );
}

class _BottonNavigationButtons extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget? forwardNavigationWidget;

  const _BottonNavigationButtons({
    required this.backNavigationWidget,
    this.forwardNavigationWidget,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (forwardNavigationWidget != null) ...[
            Expanded(child: backNavigationWidget),
            SizedBox(width: layout.formPadding.horizontalItemDistance),
            Expanded(child: forwardNavigationWidget!),
          ] else
            Center(child: backNavigationWidget),
        ],
      );
}

class _VerticalBottomNavigationButtons extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget? forwardNavigationWidget;

  const _VerticalBottomNavigationButtons({
    required this.backNavigationWidget,
    this.forwardNavigationWidget,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (forwardNavigationWidget != null) ...[
            Expanded(child: forwardNavigationWidget!),
            SizedBox(height: layout.formPadding.verticalItemDistance),
            Expanded(child: backNavigationWidget),
          ] else
            Center(child: backNavigationWidget),
        ],
      );
}
