import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class MpGoMenuPage extends StatelessWidget {
  const MpGoMenuPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return BlocBuilder<SessionsCubit, SessionsState>(
      builder: (context, sessionsState) => SettingsBasePage(
        icon: sessionsState.hasMP4Session
            ? AbiliaIcons.menu
            : AbiliaIcons.settings,
        title:
            sessionsState.hasMP4Session ? translate.menu : translate.settings,
        bottomNavigationBar:
            const BottomNavigation(backNavigationWidget: CloseButton()),
        widgets: [
          if (sessionsState.hasMP4Session) ...[
            const MyPhotosPickField(),
            const SizedBox(height: 10),
            const Divider(),
          ],
          Tts(child: Text(translate.calendar)),
          MenuItemPickField(
            icon: AbiliaIcons.handiAlarmVibration,
            text: translate.alarmSettings,
            navigateTo: const AlarmSettingsPage(),
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          Tts(child: Text(translate.system)),
          const TextToSpeechSwitch(),
          const PermissionPickField(),
          MenuItemPickField(
            icon: AbiliaIcons.information,
            text: translate.about,
            navigateTo: const AboutPage(),
          ),
          MenuItemPickField(
            icon: AbiliaIcons.powerOffOn,
            text: translate.logout,
            navigateTo: const LogoutPage(),
          ),
          if (Config.dev)
            const MenuItemPickField(
              icon: AbiliaIcons.commands,
              text: 'Feature toggles',
              navigateTo: FeatureTogglesPage(),
            ),
        ],
      ),
    );
  }
}

class MyPhotosPickField extends StatelessWidget {
  const MyPhotosPickField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = (Theme.of(context).textTheme.bodyLarge ?? bodyLarge);
    final text = Lt.of(context).myPhotos;
    return BlocSelector<SortableBloc, SortableState, String?>(
      selector: (state) => state is SortablesLoaded
          ? state.sortables.getMyPhotosFolder()?.id
          : null,
      builder: (context, myPhotoFolderId) => Material(
        borderRadius: borderRadius,
        textStyle: textStyle.copyWith(
          color: AbiliaColors.white,
          overflow: TextOverflow.ellipsis,
        ),
        child: IconTheme(
          data: Theme.of(context).iconTheme.copyWith(color: AbiliaColors.white),
          child: Tts.fromSemantics(
            SemanticsProperties(label: text, button: true),
            child: InkWell(
              onTap: myPhotoFolderId != null
                  ? () async {
                      final authProviders = copiedAuthProviders(context);
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: authProviders,
                            child:
                                MyPhotosPage(myPhotoFolderId: myPhotoFolderId),
                          ),
                          settings: (MyPhotosPage).routeSetting(),
                        ),
                      );
                    }
                  : null,
              borderRadius: borderRadius,
              child: Ink(
                height: layout.pickField.height,
                decoration: blueBoxDecoration,
                padding: layout.pickField.padding,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: layout.pickField.leadingPadding,
                      child: Icon(
                        AbiliaIcons.myPhotos,
                        size: layout.icon.small,
                      ),
                    ),
                    Text(text),
                    const Spacer(),
                    const Icon(AbiliaIcons.navigationNext),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
