import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class InfoItemTab extends StatelessWidget with EditActivityTab {
  final bool showNote, showChecklist;

  const InfoItemTab({
    Key? key,
    this.showNote = true,
    this.showChecklist = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) {
        final translate = Translator.of(context).translate;
        final activity = state.activity;
        final infoItem = activity.infoItem;

        Future onTap() async {
          final result = await Navigator.of(context).push<Type>(
            MaterialPageRoute(
              builder: (context) => SelectInfoTypePage(
                infoItemType: activity.infoItem.runtimeType,
                showChecklist: showChecklist,
                showNote: showNote,
              ),
            ),
          );
          if (result != null) {
            context.read<EditActivityCubit>().changeInfoItemType(result);
          }
        }

        return padded(
          Padding(
            padding: EdgeInsets.only(right: 12.0.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SubHeading(translate.infoType),
                if (infoItem is Checklist)
                  EditChecklistWidget(
                    activity: activity,
                    checklist: infoItem,
                    onTap: onTap,
                  )
                else if (infoItem is NoteInfoItem)
                  EditNoteWidget(
                    activity: activity,
                    infoItem: infoItem,
                    onTap: onTap,
                  )
                else
                  PickField(
                    key: TestKey.changeInfoItem,
                    leading: const Icon(AbiliaIcons.information),
                    text: Text(translate.infoTypeNone),
                    onTap: onTap,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EditChecklistWidget extends StatelessWidget {
  final Activity activity;
  final Checklist checklist;
  final GestureTapCallback onTap;

  const EditChecklistWidget({
    Key? key,
    required this.activity,
    required this.checklist,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Expanded(
      child: Column(children: [
        Row(
          children: <Widget>[
            Expanded(
              child: PickField(
                key: TestKey.changeInfoItem,
                leading: const Icon(AbiliaIcons.ok),
                text: Text(translate.infoTypeChecklist),
                onTap: onTap,
              ),
            ),
            _LibraryButton(
              onPressed: () async {
                final selectedChecklist =
                    await Navigator.of(context).push<Checklist>(
                  MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                      blocContext: context,
                      child: const ChecklistLibraryPage(),
                    ),
                  ),
                );
                if (selectedChecklist != null &&
                    selectedChecklist != checklist) {
                  context.read<EditActivityCubit>().replaceActivity(
                        activity.copyWith(infoItem: selectedChecklist),
                      );
                }
              },
            )
          ],
        ),
        SizedBox(height: 16.0.s),
        Expanded(
          child: GestureDetector(
            child: Container(
              decoration: whiteBoxDecoration,
              padding: EdgeInsets.fromLTRB(12.0.s, 0, 0, 12.0.s),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.0.s),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AbiliaColors.white120),
                        ),
                      ),
                      child: ChecklistView(
                        checklist,
                        padding:
                            EdgeInsets.fromLTRB(0.0, 12.0.s, 16.0.s, 25.0.s),
                        onTap: (r) => _handleEditQuestionResult(r, context),
                        preview: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16.0.s),
                    child: Tts.data(
                      data: Translator.of(context).translate.addNew,
                      child: RawMaterialButton(
                        constraints: BoxConstraints(minHeight: 48.0.s),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: AbiliaColors.green140),
                          borderRadius: borderRadius,
                        ),
                        fillColor: AbiliaColors.green,
                        elevation: 0.0,
                        disabledElevation: 0.0,
                        focusElevation: 0.0,
                        highlightElevation: 0.0,
                        hoverElevation: 0.0,
                        onPressed: () => _handleNewQuestion(context),
                        child: Row(
                          children: [
                            SizedBox(width: 12.0.s),
                            Icon(AbiliaIcons.newIcon,
                                size: layout.iconSize.small),
                            SizedBox(width: 12.0.s),
                            Text(
                              Translator.of(context).translate.addNew,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void _handleEditQuestionResult(
      final Question oldQuestion, BuildContext context) async {
    final result = await Navigator.of(context).push<ImageAndName>(
      MaterialPageRoute(
        builder: (_) => CopiedAuthProviders(
          blocContext: context,
          child: EditQuestionPage(
            question: oldQuestion,
          ),
        ),
      ),
    );
    bool changed(ImageAndName imageAndName) =>
        imageAndName.name != oldQuestion.name ||
        imageAndName.image.id != oldQuestion.fileId;

    if (result != null && changed(result)) {
      final questionMap = {for (var q in checklist.questions) q.id: q};
      if (result.isEmpty) {
        questionMap.remove(oldQuestion.id);
      } else {
        questionMap[oldQuestion.id] = Question(
          id: oldQuestion.id,
          name: result.name,
          fileId: result.image.id,
          image: result.image.path,
        );
      }

      context.read<EditActivityCubit>().replaceActivity(
            activity.copyWith(
              infoItem: checklist.copyWith(questions: questionMap.values),
            ),
          );
    }
  }

  void _handleNewQuestion(BuildContext context) async {
    final result = await Navigator.of(context).push<ImageAndName>(
      MaterialPageRoute(
        builder: (_) => CopiedAuthProviders(
          blocContext: context,
          child: const EditQuestionPage(),
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      final uniqueId = DateTime.now().millisecondsSinceEpoch;

      context.read<EditActivityCubit>().replaceActivity(
            activity.copyWith(
              infoItem: checklist.copyWith(
                questions: [
                  ...checklist.questions,
                  Question(
                    id: uniqueId,
                    name: result.name,
                    fileId: result.image.id,
                    image: result.image.path,
                  ),
                ],
              ),
            ),
          );
    }
  }
}

class EditNoteWidget extends StatelessWidget {
  final Activity activity;
  final NoteInfoItem infoItem;
  final GestureTapCallback onTap;

  const EditNoteWidget({
    Key? key,
    required this.activity,
    required this.infoItem,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Expanded(
      child: Column(children: [
        Row(
          children: <Widget>[
            Expanded(
              child: PickField(
                key: TestKey.changeInfoItem,
                leading: const Icon(AbiliaIcons.edit),
                text: Text(translate.infoTypeNote),
                onTap: onTap,
              ),
            ),
            _LibraryButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                      blocContext: context,
                      child: const NoteLibraryPage(),
                    ),
                  ),
                );
                if (result != null && result != infoItem.text) {
                  context.read<EditActivityCubit>().replaceActivity(
                        activity.copyWith(
                          infoItem: NoteInfoItem(result),
                        ),
                      );
                }
              },
            )
          ],
        ),
        SizedBox(height: 16.0.s),
        Expanded(
          child: GestureDetector(
            onTap: () => editText(context, activity, infoItem),
            child: Container(
              decoration: whiteBoxDecoration,
              child: NoteBlock(
                text: infoItem.text,
                textWidget: infoItem.text.isEmpty
                    ? Text(
                        Translator.of(context).translate.typeSomething,
                        style: abiliaTextTheme.bodyText1
                            ?.copyWith(color: const Color(0xff747474)),
                      )
                    : Text(infoItem.text),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Future editText(
    BuildContext context,
    Activity activity,
    NoteInfoItem infoItem,
  ) async {
    final result = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CopiedAuthProviders(
          blocContext: context,
          child: EditNotePage(text: infoItem.text),
        ),
        settings: const RouteSettings(name: 'EditNotePage'),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        ),
      ),
    );
    if (result != null && result != infoItem.text) {
      context.read<EditActivityCubit>().replaceActivity(
            activity.copyWith(
              infoItem: NoteInfoItem(result),
            ),
          );
    }
  }
}

class _LibraryButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _LibraryButton({Key? key, this.onPressed}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.0.s, 4.0.s, 4.0.s, 4.0.s),
      child: ActionButtonDark(
        onPressed: onPressed,
        child: Icon(
          AbiliaIcons.showText,
          size: layout.iconSize.normal,
          color: AbiliaColors.black,
        ),
      ),
    );
  }
}
