import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EditQuestionBottomSheet extends StatelessWidget {
  final Question? question;

  const EditQuestionBottomSheet({
    this.question,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final question = this.question;
    return EditImageAndName(
      maxLines: 8,
      minLines: 1,
      allowEmpty: false,
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
        title: t.enterTask,
        borderRadius: layout.appBar.borderRadius,
      ),
    );
  }
}
