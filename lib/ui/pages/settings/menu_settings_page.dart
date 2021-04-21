import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MenuSettingsPage extends StatefulWidget {
  const MenuSettingsPage({Key key}) : super(key: key);

  @override
  _MenuSettingsPageState createState() => _MenuSettingsPageState();
}

class _MenuSettingsPageState extends State<MenuSettingsPage> {
  bool camera,
      myPhotos,
      photoCalendar,
      countdown,
      quickSettings,
      settings,
      settingsInitial;

  @override
  void initState() {
    super.initState();
    final memosettingsState = context.read<MemoplannerSettingBloc>().state;
    camera = memosettingsState.displayMenuCamera;
    myPhotos = memosettingsState.displayMenuMyPhotos;
    photoCalendar = memosettingsState.displayMenuPhotoCalendar;
    countdown = memosettingsState.displayMenuCountdown;
    quickSettings = memosettingsState.displayMenuQuickSettings;
    settingsInitial = settings = memosettingsState.displayMenuSettings;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsBasePage(
      icon: AbiliaIcons.app_menu,
      title: Translator.of(context).translate.menu,
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: Builder(
          builder: (context) => OkButton(
            onPressed: () async {
              final settingsChangeToDisable = settingsInitial && !settings;
              if (settingsChangeToDisable) {
                final answer = await showViewDialog<bool>(
                  context: context,
                  builder: (context) => YesNoDialog(
                    heading: t.menu,
                    text: t.menuRemovalWarning,
                  ),
                );
                if (answer != true) return;
              }
              context.read<GenericBloc>().add(
                    GenericUpdated(
                      [
                        MemoplannerSettingData.fromData(
                          data: camera,
                          identifier:
                              MemoplannerSettings.settingsMenuShowCameraKey,
                        ),
                        MemoplannerSettingData.fromData(
                          data: myPhotos,
                          identifier:
                              MemoplannerSettings.settingsMenuShowPhotosKey,
                        ),
                        MemoplannerSettingData.fromData(
                          data: photoCalendar,
                          identifier: MemoplannerSettings
                              .settingsMenuShowPhotoCalendarKey,
                        ),
                        MemoplannerSettingData.fromData(
                          data: countdown,
                          identifier:
                              MemoplannerSettings.settingsMenuShowTimersKey,
                        ),
                        MemoplannerSettingData.fromData(
                          data: quickSettings,
                          identifier: MemoplannerSettings
                              .settingsMenuShowQuickSettingsKey,
                        ),
                        MemoplannerSettingData.fromData(
                          data: settings,
                          identifier:
                              MemoplannerSettings.settingsMenuShowSettingsKey,
                        ),
                      ],
                    ),
                  );
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      widgets: [
        SwitchField(
          leading: Icon(AbiliaIcons.camera_photo),
          text: Text(t.camera),
          value: camera,
          onChanged: (v) => setState(() => camera = v),
        ),
        SwitchField(
          leading: Icon(AbiliaIcons.my_photos),
          text: Text(t.myPhotos),
          value: myPhotos,
          onChanged: (v) => setState(() => myPhotos = v),
        ),
        SwitchField(
          leading: Icon(AbiliaIcons.day),
          text: Text(t.photoCalendar.singleLine),
          value: photoCalendar,
          onChanged: (v) => setState(() => photoCalendar = v),
        ),
        SwitchField(
          leading: Icon(AbiliaIcons.stop_watch),
          text: Text(t.countdown),
          value: countdown,
          onChanged: (v) => setState(() => countdown = v),
        ),
        SwitchField(
          leading: Icon(AbiliaIcons.menu_setup),
          text: Text(t.quickSettingsMenu.singleLine),
          value: quickSettings,
          onChanged: (v) => setState(() => quickSettings = v),
        ),
        SwitchField(
          leading: Icon(AbiliaIcons.settings),
          text: Text(t.settings),
          value: settings,
          onChanged: (v) => setState(() => settings = v),
        ),
      ],
    );
  }
}
