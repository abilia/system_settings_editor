import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, state) {
        return Stack(
          overflow: Overflow.visible,
          children: [
            ActionButton(
              child: const Icon(AbiliaIcons.app_menu),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CopiedAuthProviders(
                    blocContext: context,
                    child: MenuPage(),
                  ),
                  settings: RouteSettings(name: 'MenuPage'),
                ),
              ),
            ),
            if (state.importantPermissionMissing)
              const Positioned(
                top: -3,
                right: -3,
                child: OrangeDot(),
              ),
          ],
        );
      },
    );
  }
}