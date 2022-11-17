import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/session.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

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
            BlocBuilder<SessionCubit, Session>(
              builder: (context, session) => IconActionButton(
                style: actionButtonStyleLight,
                ttsData: t.menu,
                onPressed: () {
                  final authProviders = copiedAuthProviders(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: authProviders,
                        child: const MpGoMenuPage(),
                      ),
                      settings: const RouteSettings(name: 'MpGoMenuPage'),
                    ),
                  );
                },
                child: Icon(session.isMP4Session
                    ? AbiliaIcons.menu
                    : AbiliaIcons.settings),
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
