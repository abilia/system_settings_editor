import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EditCategoryPage extends StatelessWidget {
  final ImageAndName? imageAndName;
  final String hintText;

  const EditCategoryPage({
    this.imageAndName,
    required this.hintText,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final label = Translator.of(context).translate.general;
    return EditImageAndName(
      maxLines: 1,
      minLines: 1,
      allowEmpty: true,
      hintText: hintText,
      imageAndName: imageAndName,
      selectPictureLabel: Config.isMP ? label : null,
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.phoneLog,
        title: Translator.of(context).translate.editCategory,
        label: Config.isMP ? label : null,
      ),
    );
  }
}
