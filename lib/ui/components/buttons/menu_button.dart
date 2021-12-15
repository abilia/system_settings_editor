import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PermissionBloc, PermissionState, bool>(
      selector: (state) => state.importantPermissionMissing,
      builder: (context, importantPermissionMissing) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            TextActionButtonLight(
              Translator.of(context).translate.menu,
              AbiliaIcons.appMenu,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CopiedAuthProviders(
                    blocContext: context,
                    child: const MenuPage(),
                  ),
                  settings: const RouteSettings(name: 'MenuPage'),
                ),
              ),
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
