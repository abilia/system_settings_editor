import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
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
        final t = Translator.of(context).translate;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            BlocBuilder<SessionCubit, bool>(
              builder: (context, hasMP4Session) =>
                  TextAndOrIconActionButtonLight(
                hasMP4Session ? t.menu : t.settings,
                hasMP4Session ? AbiliaIcons.menu : AbiliaIcons.settings,
                ttsData: t.menu,
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final authProviders = copiedAuthProviders(context);
                  final accessGranted = await codeProtectAccess(
                    context,
                    restricted: (codeSettings) => codeSettings.protectSettings,
                    name: t.settings,
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
