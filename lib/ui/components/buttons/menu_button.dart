// @dart=2.9

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
                      child: const MenuPage(),
                    ),
                    settings: RouteSettings(name: 'MenuPage'),
                  ),
                ),
                child: const Icon(AbiliaIcons.app_menu),
              )
            else if (Config.isMPGO)
              ActionButtonLight(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                      blocContext: context,
                      child: const SettingsPage(),
                    ),
                    settings: RouteSettings(name: 'SettingsPage'),
                  ),
                ),
                child: const Icon(AbiliaIcons.settings),
              ),
            if (state.importantPermissionMissing)
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
