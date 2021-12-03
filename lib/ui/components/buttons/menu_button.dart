import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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
            ActionButtonLight(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CopiedAuthProviders(
                    blocContext: context,
                    child: const MenuPage(),
                  ),
                  settings: const RouteSettings(name: 'MenuPage'),
                ),
              ),
              child: const Icon(AbiliaIcons.appMenu),
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
