import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/session/session_cubit.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MpGoMenuPage extends StatelessWidget {
  const MpGoMenuPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<SessionCubit, bool>(
      builder: (context, hasMP4Session) => SettingsBasePage(
        icon: AbiliaIcons.menu,
        title: t.menu,
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
    return BlocSelector<SortableBloc, SortableState, String?>(
      selector: (state) => state is SortablesLoaded
          ? state.sortables.getMyPhotosFolder()?.id
          : null,
      builder: (context, myPhotoFolderId) => DefaultTextStyle(
        style: const TextStyle(color: AbiliaColors.white),
        child: Tts.fromSemantics(
          SemanticsProperties(
            label: Translator.of(context).translate.myPhotos,
            button: true,
          ),
          child: Material(
            color: Colors.transparent,
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
                    IconTheme(
                      data: Theme.of(context).iconTheme.copyWith(
                            size: layout.icon.small,
                            color: AbiliaColors.white,
                          ),
                      child: Padding(
                        padding: layout.pickField.leadingPadding,
                        child: const Icon(AbiliaIcons.myPhotos),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle(
                            overflow: TextOverflow.ellipsis,
                            style: (Theme.of(context).textTheme.bodyText1 ??
                                    bodyText1)
                                .copyWith(
                              color: AbiliaColors.white,
                            ),
                            child:
                                Text(Translator.of(context).translate.myPhotos),
                          ),
                        ],
                      ),
                    ),
                    // ignore: prefer_const_constructors
                    Icon(
                      AbiliaIcons.navigationNext,
                      color: AbiliaColors.white,
                    ),
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
