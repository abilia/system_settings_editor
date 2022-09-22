import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MpGoMenuPage extends StatelessWidget {
  const MpGoMenuPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<SessionCubit, bool>(
      builder: (context, hasMP4Session) => SettingsBasePage(
        icon: hasMP4Session ? AbiliaIcons.menu : AbiliaIcons.settings,
        title: hasMP4Session ? t.menu : t.settings,
        bottomNavigationBar:
            const BottomNavigation(backNavigationWidget: CloseButton()),
        widgets: [
          if (hasMP4Session) ...[
            const MyPhotosPickField(),
            const SizedBox(height: 10),
            const Divider(),
          ],
          Tts(child: Text(t.calendar)),
          MenuItemPickField(
            icon: AbiliaIcons.handiAlarmVibration,
            text: t.alarmSettings,
            navigateTo: const AlarmSettingsPage(),
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance),
          Tts(child: Text(t.system)),
          const TextToSpeechSwitch(),
          const PermissionPickField(),
          MenuItemPickField(
            icon: AbiliaIcons.information,
            text: t.about,
            navigateTo: const AboutPage(),
          ),
          MenuItemPickField(
            icon: AbiliaIcons.powerOffOn,
            text: t.logout,
            navigateTo: const LogoutPage(),
          ),
          if (Config.alpha) const FakeTicker(),
        ],
      ),
    );
  }
}

class MyPhotosPickField extends StatelessWidget {
  const MyPhotosPickField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = (Theme.of(context).textTheme.bodyText1 ?? bodyText1);
    final text = Translator.of(context).translate.myPhotos;
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
                  ? () {
                      final authProviders = copiedAuthProviders(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: authProviders,
                            child:
                                MyPhotosPage(myPhotoFolderId: myPhotoFolderId),
                          ),
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
