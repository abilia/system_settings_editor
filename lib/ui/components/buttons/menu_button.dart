import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    required this.tabIndex,
    Key? key,
  }) : super(key: key);

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PermissionCubit, PermissionState, bool>(
      selector: (state) => state.importantPermissionMissing,
      builder: (context, importantPermissionMissing) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            TabControlledButton(
              Translator.of(context).translate.menu,
              AbiliaIcons.appMenu,
              tabIndex: tabIndex,
            ),
            if (importantPermissionMissing)
              Positioned(
                top: layout.menuButton.dotPosition,
                right: layout.menuButton.dotPosition,
                child: const OrangeDot(),
              ),
          ],
        );
      },
    );
  }
}
