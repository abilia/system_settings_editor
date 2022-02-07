import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EditQuestionPage extends StatelessWidget {
  final Question? question;

  const EditQuestionPage({
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
        title: t.task,
        trailing: question != null
            ? Padding(
                padding: EdgeInsets.only(right: 12.0.s),
                child: RemoveButton(
                  onTap: () =>
                      Navigator.of(context).maybePop(ImageAndName.empty),
                  icon: Icon(
                    AbiliaIcons.deleteAllClear,
                    color: AbiliaColors.white,
                    size: 24.s,
                  ),
                  text: t.delete,
                ),
              )
            : null,
      ),
    );
  }
}
