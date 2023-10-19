import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class EditQuestionBottomSheet extends StatelessWidget {
  final Question? question;

  const EditQuestionBottomSheet({
    this.question,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final question = this.question;
    return EditImageAndName(
      maxLines: 8,
      minLines: 1,
      allowEmpty: false,
      nameFromImage: true,
      imageAndName: question != null
          ? ImageAndName(
              question.name,
              AbiliaFile.from(
                path: question.image,
                id: question.fileId,
              ),
            )
          : null,
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.phoneLog,
        title: translate.enterTask,
        borderRadius: layout.appBar.borderRadius,
      ),
    );
  }
}
