import 'package:seagull/ui/all.dart';

class WizardScaffold extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? bottom;

  const WizardScaffold({
    Key? key,
    required this.iconData,
    required this.title,
    required this.body,
    this.bottom,
    this.bottomNavigationBar = const WizardBottomNavigation(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AbiliaAppBar(
          iconData: iconData,
          label: Translator.of(context).translate.newActivity,
          title: title,
          bottom: bottom,
        ),
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      );
}
