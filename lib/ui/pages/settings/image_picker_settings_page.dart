import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ImagePickerSettingsPage extends StatefulWidget {
  const ImagePickerSettingsPage({Key? key}) : super(key: key);

  @override
  _ImagePickerSettingsPageState createState() =>
      _ImagePickerSettingsPageState();
}

class _ImagePickerSettingsPageState extends State<ImagePickerSettingsPage> {
  late bool displayLocalImages, displayMyPhotos, displayCamera;

  @override
  void initState() {
    super.initState();
    final memosettingsState = context.read<MemoplannerSettingBloc>().state;
    displayCamera = memosettingsState.displayCamera;
    displayMyPhotos = memosettingsState.displayMyPhotos;
    displayLocalImages = memosettingsState.displayLocalImages;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsBasePage(
      icon: AbiliaIcons.myPhotos,
      title: Translator.of(context).translate.imagePicker,
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: Builder(
          builder: (context) => OkButton(
            onPressed: () {
              final genericBloc = context.read<GenericBloc>();
              genericBloc.add(
                GenericUpdated(
                  [
                    MemoplannerSettingData.fromData(
                      data: displayMyPhotos,
                      identifier:
                          MemoplannerSettings.imageMenuDisplayMyPhotosItemKey,
                    ),
                    MemoplannerSettingData.fromData(
                      data: displayCamera,
                      identifier:
                          MemoplannerSettings.imageMenuDisplayCameraItemKey,
                    ),
                    MemoplannerSettingData.fromData(
                      data: displayLocalImages,
                      identifier:
                          MemoplannerSettings.imageMenuDisplayPhotoItemKey,
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
          leading: const Icon(AbiliaIcons.folder),
          value: true,
          child: Text(t.imageArchive),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.myPhotos),
          value: displayMyPhotos,
          onChanged: (v) => setState(() => displayMyPhotos = v),
          child: Text(t.myPhotos),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.cameraPhoto),
          value: displayCamera,
          onChanged: (v) => setState(() => displayCamera = v),
          child: Text(t.takeNewPhoto),
        ),
        if (Config.isMP) const Divider(height: 2),
        SwitchField(
          leading: const Icon(AbiliaIcons.phone),
          value: displayLocalImages,
          onChanged: (v) => setState(() => displayLocalImages = v),
          child: Text(t.devicesLocalImages),
        ),
        if (Config.isMP) Text(t.onlyAppliesToGo),
      ],
    );
  }
}
