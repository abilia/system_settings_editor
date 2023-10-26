import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class ImagePickerSettingsPage extends StatefulWidget {
  const ImagePickerSettingsPage({super.key});

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
    final translate = Lt.of(context);
    return SettingsBasePage(
      icon: AbiliaIcons.myPhotos,
      title: Lt.of(context).imagePicker,
      label: Config.isMP ? Lt.of(context).settings : null,
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: Builder(
          builder: (context) => OkButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<GenericCubit>().genericUpdated(
                [
                  MemoplannerSettingData(
                    data: _displayMyPhotos,
                    identifier: PhotoMenuSettings.displayMyPhotosKey,
                  ),
                  MemoplannerSettingData(
                    data: _displayCamera,
                    identifier: PhotoMenuSettings.displayCameraKey,
                  ),
                  MemoplannerSettingData(
                    data: _displayLocalImages,
                    identifier: PhotoMenuSettings.displayPhotoKey,
                  ),
                ],
              );
            },
          ),
        ),
      ),
      widgets: [
        SwitchField(
          leading: const Icon(AbiliaIcons.folder),
          value: true,
          child: Text(translate.imageArchive),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.myPhotos),
          value: _displayMyPhotos,
          onChanged: (v) => setState(() => _displayMyPhotos = v),
          child: Text(translate.myPhotos),
        ),
        SwitchField(
          leading: const Icon(AbiliaIcons.cameraPhoto),
          value: _displayCamera,
          onChanged: (v) => setState(() => _displayCamera = v),
          child: Text(translate.takeNewPhoto),
        ),
        const Divider(),
        SwitchField(
          leading: const Icon(AbiliaIcons.phone),
          value: _displayLocalImages,
          onChanged: (v) => setState(() => _displayLocalImages = v),
          child: Text(translate.devicesLocalImages),
        ),
        Tts(child: Text(translate.onlyAppliesToGo)),
      ],
    );
  }
}
