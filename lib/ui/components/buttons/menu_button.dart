import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    Key? key,
    required this.tabIndex,
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
                top: -3.s,
                right: -3.s,
                child: const OrangeDot(),
              ),
          ],
        );
      },
    );
  }
}
