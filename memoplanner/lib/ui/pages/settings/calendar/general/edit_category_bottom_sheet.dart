import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class EditCategoryBottomSheet extends StatelessWidget {
  final ImageAndName? imageAndName;
  final String hintText;

  const EditCategoryBottomSheet({
    required this.hintText,
    this.imageAndName,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final label = Lt.of(context).general;
    return EditImageAndName(
      maxLines: 1,
      minLines: 1,
      allowEmpty: true,
      hintText: hintText,
      imageAndName: imageAndName,
      selectPictureLabel: Config.isMP ? label : null,
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.phoneLog,
        title: Lt.of(context).editCategory,
        label: Config.isMP ? label : null,
        borderRadius: layout.appBar.borderRadius,
      ),
    );
  }
}
