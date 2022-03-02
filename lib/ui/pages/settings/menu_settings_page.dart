import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MenuSettingsPage extends StatefulWidget {
  const MenuSettingsPage({Key? key}) : super(key: key);

  @override
  _MenuSettingsPageState createState() => _MenuSettingsPageState();
}

class _MenuSettingsPageState extends State<MenuSettingsPage> {
  late bool camera,
      myPhotos,
      photoCalendar,
      countdown,
      quickSettings,
      settings,
      settingsInitial;

  @override
  void initState() {
    super.initState();
    final memosettingsState =
        context.read<MemoplannerSettingBloc>().state.settings.menu;
    camera = memosettingsState.showCamera;
    myPhotos = memosettingsState.showPhotos;
    photoCalendar = memosettingsState.showPhotoCalendar;
    countdown = memosettingsState.showTimers;
    quickSettings = memosettingsState.showQuickSettings;
    settingsInitial = settings = memosettingsState.showSettings;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsBasePage(
      icon: AbiliaIcons.appMenu,
      title: Translator.of(context).translate.menu,
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
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
              context.read<GenericCubit>().genericUpdated(
                [
                  MemoplannerSettingData.fromData(
                    data: camera,
                    identifier: MenuSettings.showCameraKey,
                  ),
                  MemoplannerSettingData.fromData(
                    data: myPhotos,
                    identifier: MenuSettings.showPhotosKey,
                  ),
                  MemoplannerSettingData.fromData(
                    data: photoCalendar,
                    identifier: MenuSettings.showPhotoCalendarKey,
                  ),
                  MemoplannerSettingData.fromData(
                    data: countdown,
                    identifier: MenuSettings.showTimersKey,
                  ),
                  MemoplannerSettingData.fromData(
                    data: quickSettings,
                    identifier: MenuSettings.showQuickSettingsKey,
                  ),
                  MemoplannerSettingData.fromData(
                    data: settings,
                    identifier: MenuSettings.showSettingsKey,
                  ),
                ],
              );
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      widgets: [
        SwitchField(
          leading: const Icon(AbiliaIcons.cameraPhoto),
          value: camera,
          onChanged: (v) => setState(() => camera = v),
          child: Text(t.camera),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.myPhotos),
          value: myPhotos,
          onChanged: (v) => setState(() => myPhotos = v),
          child: Text(t.myPhotos),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.day),
          value: photoCalendar,
          onChanged: (v) => setState(() => photoCalendar = v),
          child: Text(t.photoCalendar.singleLine),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.stopWatch),
          value: countdown,
          onChanged: (v) => setState(() => countdown = v),
          child: Text(t.countdown),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.menuSetup),
          value: quickSettings,
          onChanged: (v) => setState(() => quickSettings = v),
          child: Text(t.quickSettingsMenu.singleLine),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.settings),
          value: settings,
          onChanged: (v) => setState(() => settings = v),
          child: Text(t.settings),
        ),
      ],
    );
  }
}
