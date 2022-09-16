import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/mp_go_menu_page.dart';
import 'package:seagull/utils/all.dart';

class MpGoMenuButton extends StatelessWidget {
  const MpGoMenuButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PermissionCubit, PermissionState, bool>(
      selector: (state) => state.importantPermissionMissing,
      builder: (context, importantPermissionMissing) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            TextAndOrIconActionButtonLight(
              Translator.of(context).translate.menu,
              AbiliaIcons.menu,
              ttsData: Translator.of(context).translate.menu,
              onPressed: () async {
                final navigator = Navigator.of(context);
                final authProviders = copiedAuthProviders(context);
                final accessGranted = await codeProtectAccess(
                  context,
                  restricted: (codeSettings) => codeSettings.protectSettings,
                  name: Translator.of(context).translate.settings,
                );
                if (accessGranted) {
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: authProviders,
                        child: const MpGoMenuPage(),
                      ),
                      settings: const RouteSettings(name: 'MpGoMenuPage'),
                    ),
                  );
                }
              },
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
