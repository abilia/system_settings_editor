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
      showBasicTemplates,
      quickSettings,
      settings;
  late final bool settingsInitial;

  @override
  void initState() {
    super.initState();
    final memosettingsState =
        context.read<MemoplannerSettingBloc>().state.settings.menu;
    camera = memosettingsState.showCamera;
    myPhotos = memosettingsState.showPhotos;
    photoCalendar = memosettingsState.showPhotoCalendar;
    showBasicTemplates = memosettingsState.showBasicTemplates;
    quickSettings = memosettingsState.showQuickSettings;
    settingsInitial = settings = memosettingsState.showSettings;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsBasePage(
      icon: AbiliaIcons.appMenu,
      title: Translator.of(context).translate.menu,
      label: Config.isMP ? Translator.of(context).translate.settings : null,
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: Builder(
          builder: (context) => OkButton(
            onPressed: () async {
              final settingsChangeToDisable = settingsInitial && !settings;
              final genericCubit = context.read<GenericCubit>();
              final navigator = Navigator.of(context);
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
              genericCubit.genericUpdated(
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
                    data: showBasicTemplates,
                    identifier: MenuSettings.showBasicTemplatesKey,
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
              navigator.pop();
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
          leading: const Icon(AbiliaIcons.photoCalendar),
          value: photoCalendar,
          onChanged: (v) => setState(() => photoCalendar = v),
          child: Text(t.photoCalendar.singleLine),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.favoritesShow),
          value: showBasicTemplates,
          onChanged: (v) => setState(() => showBasicTemplates = v),
          child: Text(t.templates.singleLine),
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
