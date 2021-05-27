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
            if (Config.isMP)
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
              )
            else
              ActionButtonLight(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                      blocContext: context,
                      child: SystemSettingsPage(),
                    ),
                    settings: RouteSettings(name: 'SystemSettingsPage'),
                  ),
                ),
                child: const Icon(AbiliaIcons.technical_settings),
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
