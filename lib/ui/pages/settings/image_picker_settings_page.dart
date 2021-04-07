import 'package:seagull/ui/all.dart';

class ImagePickerSettingsPage extends StatelessWidget {
  const ImagePickerSettingsPage({Key key}) : super(key: key);
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    return SettingsBasePage(
      widgets: [],
      icon: AbiliaIcons.my_photos,
      title: Translator.of(context).translate.imagePicker,
    );
  }
}
