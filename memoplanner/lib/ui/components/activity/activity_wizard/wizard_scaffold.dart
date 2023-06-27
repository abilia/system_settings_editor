import 'package:memoplanner/ui/all.dart';

class WizardScaffold extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar, appBarTrailing;
  final double? appBarHeight;
  final PreferredSizeWidget? bottom;
  final bool showAppBar;
  final Color? backgroundColor;

  const WizardScaffold({
    required this.iconData,
    required this.title,
    required this.body,
    this.bottom,
    this.bottomNavigationBar = const WizardBottomNavigation(),
    this.appBarTrailing,
    this.appBarHeight,
    this.showAppBar = true,
    this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: backgroundColor,
        appBar: showAppBar
            ? AbiliaAppBar(
                iconData: iconData,
                label: Lt.of(context).newActivity,
                height: appBarHeight,
                title: title,
                bottom: bottom,
                trailing: appBarTrailing,
              )
            : null,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      );
}
