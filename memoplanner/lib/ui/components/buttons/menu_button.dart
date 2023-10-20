import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.read<MemoplannerSettingsBloc>().state;
    final tabIndex = settings.functions.display.menuTabIndex;
    return TabControlledButton(
      Lt.of(context).menu,
      AbiliaIcons.appMenu,
      tabIndex: tabIndex,
    );
  }
}
