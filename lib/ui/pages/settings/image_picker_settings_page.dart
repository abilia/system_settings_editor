import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ImagePickerSettingsPage extends StatefulWidget {
  const ImagePickerSettingsPage({Key? key}) : super(key: key);

  @override
  State createState() => _ImagePickerSettingsPageState();
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
      label: Config.isMP ? Translator.of(context).translate.settings : null,
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: Builder(
          builder: (context) => OkButton(
            onPressed: () {
              context.read<GenericCubit>().genericUpdated(
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
        const Divider(),
        SwitchField(
          leading: const Icon(AbiliaIcons.phone),
          value: displayLocalImages,
          onChanged: (v) => setState(() => displayLocalImages = v),
          child: Text(t.devicesLocalImages),
        ),
        Tts(child: Text(t.onlyAppliesToGo)),
      ],
    );
  }
}
