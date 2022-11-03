import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class ImagePickerSettingsPage extends StatefulWidget {
  const ImagePickerSettingsPage({Key? key}) : super(key: key);

  @override
  State createState() => _ImagePickerSettingsPageState();
}

class _ImagePickerSettingsPageState extends State<ImagePickerSettingsPage> {
  late bool _displayLocalImages, _displayMyPhotos, _displayCamera;

  @override
  void initState() {
    super.initState();
    final photoMenuSettings =
        context.read<MemoplannerSettingsBloc>().state.photoMenu;
    _displayCamera = photoMenuSettings.displayCamera;
    _displayMyPhotos = photoMenuSettings.displayMyPhotos;
    _displayLocalImages = photoMenuSettings.displayLocalImages;
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
                    data: _displayMyPhotos,
                    identifier: PhotoMenuSettings.displayMyPhotosKey,
                  ),
                  MemoplannerSettingData.fromData(
                    data: _displayCamera,
                    identifier: PhotoMenuSettings.displayCameraKey,
                  ),
                  MemoplannerSettingData.fromData(
                    data: _displayLocalImages,
                    identifier: PhotoMenuSettings.displayPhotoKey,
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
          value: _displayMyPhotos,
          onChanged: (v) => setState(() => _displayMyPhotos = v),
          child: Text(t.myPhotos),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.cameraPhoto),
          value: _displayCamera,
          onChanged: (v) => setState(() => _displayCamera = v),
          child: Text(t.takeNewPhoto),
        ),
        const Divider(),
        SwitchField(
          leading: const Icon(AbiliaIcons.phone),
          value: _displayLocalImages,
          onChanged: (v) => setState(() => _displayLocalImages = v),
          child: Text(t.devicesLocalImages),
        ),
        Tts(child: Text(t.onlyAppliesToGo)),
      ],
    );
  }
}
