import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.read<MemoplannerSettingsBloc>().state;
    final tabIndex = settings.functions.display.menuTabIndex;
    return TabControlledButton(
      Translator.of(context).translate.menu,
      AbiliaIcons.appMenu,
      tabIndex: tabIndex,
    );
  }
}
