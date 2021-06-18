// @dart=2.9

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ImagePickerSettingsPage extends StatefulWidget {
  const ImagePickerSettingsPage({Key key}) : super(key: key);

  @override
  _ImagePickerSettingsPageState createState() =>
      _ImagePickerSettingsPageState();
}

class _ImagePickerSettingsPageState extends State<ImagePickerSettingsPage> {
  bool displayPhotos, displayCamera;

  @override
  void initState() {
    super.initState();
    final memosettingsState = context.read<MemoplannerSettingBloc>().state;
    displayCamera = memosettingsState.displayCamera;
    displayPhotos = memosettingsState.displayPhotos;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsBasePage(
      icon: AbiliaIcons.my_photos,
      title: Translator.of(context).translate.imagePicker,
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: Builder(
          builder: (context) => OkButton(
            onPressed: () {
              final genericBloc = context.read<GenericBloc>();
              genericBloc.add(
                GenericUpdated(
                  [
                    MemoplannerSettingData.fromData(
                      data: displayCamera,
                      identifier:
                          MemoplannerSettings.imageMenuDisplayCameraItemKey,
                    ),
                    MemoplannerSettingData.fromData(
                      data: displayPhotos,
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
          leading: Icon(AbiliaIcons.folder),
          value: true,
          child: Text(t.imageArchive),
        ),
        SwitchField(
          leading: Icon(AbiliaIcons.my_photos),
          value: displayPhotos,
          onChanged: (v) => setState(() => displayPhotos = v),
          child: Text(t.myPhotos),
        ),
        SwitchField(
          leading: Icon(AbiliaIcons.camera_photo),
          value: displayCamera,
          onChanged: (v) => setState(() => displayCamera = v),
          child: Text(t.takeNewPhoto),
        ),
      ],
    );
  }
}
