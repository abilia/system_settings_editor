import 'package:seagull/ui/all.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    required this.tabIndex,
    Key? key,
  }) : super(key: key);

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return TabControlledButton(
      Translator.of(context).translate.menu,
      AbiliaIcons.appMenu,
      tabIndex: tabIndex,
    );
  }
}
