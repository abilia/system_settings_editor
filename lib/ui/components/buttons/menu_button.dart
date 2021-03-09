import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ActionButtonLight(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CopiedAuthProviders(
                    blocContext: context,
                    child: MenuPage(),
                  ),
                  settings: RouteSettings(name: 'MenuPage'),
                ),
              ),
              child: const Icon(AbiliaIcons.app_menu),
            ),
            if (state.importantPermissionMissing)
              Positioned(
                top: -3.s,
                right: -3.s,
                child: OrangeDot(),
              ),
          ],
        );
      },
    );
  }
}
