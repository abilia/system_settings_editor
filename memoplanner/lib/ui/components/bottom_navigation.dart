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
                  ? _verticalBottomNavigationButtons(
                      backNavigationWidget,
                      forwardNavigationWidget,
                    )
                  : _bottomNavigationButtons(
                      backNavigationWidget, forwardNavigationWidget),
            ),
          ),
        ),
      );
}

Widget _bottomNavigationButtons(
        Widget backNavigationWidget, Widget? forwardNavigationWidget) =>
    Row(
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

Widget _verticalBottomNavigationButtons(
        Widget backNavigationWidget, Widget? forwardNavigationWidget) =>
    Column(
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
