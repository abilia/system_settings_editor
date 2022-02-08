import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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
                final authProviders = copiedAuthProviders(context);
                final selectedChecklist =
                    await Navigator.of(context).push<Checklist>(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: authProviders,
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
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ChecklistView.withToolbar(
                      checklist,
                      padding: layout.checkList.questionListPadding,
                      onTapEdit: (r) => _handleEditQuestionResult(r, context),
                      onTapDelete: (q) => _handleDeleteQuestion(q, context),
                      onTapReorder: (q, d) =>
                          _handleReorderQuestion(q, d, context),
                      preview: true,
                    ),
                  ),
                  Divider(
                    height: layout.checkList.dividerHeight,
                    endIndent: 0,
                    indent: layout.checkList.dividerIndentation,
                  ),
                  Padding(
                    padding: layout.checkList.addNewQButtonPadding,
                    child: Tts.data(
                      data: Translator.of(context).translate.addNew,
                      child: RawMaterialButton(
                        constraints: BoxConstraints(
                          minHeight: layout.checkList.questionViewHeight,
                        ),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: AbiliaColors.green140),
                          borderRadius: borderRadius,
                        ),
                        fillColor: AbiliaColors.green,
                        elevation: 0,
                        disabledElevation: 0,
                        focusElevation: 0,
                        highlightElevation: 0,
                        hoverElevation: 0,
                        onPressed: () => _handleNewQuestion(context),
                        child: Row(
                          children: [
                            Padding(
                              padding: layout.checkList.addNewQIconPadding,
                              child: Icon(
                                AbiliaIcons.newIcon,
                                size: layout.iconSize.small,
                                color: AbiliaColors.white,
                              ),
                            ),
                            Text(
                              Translator.of(context).translate.addNew,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(
                                    height: 1,
                                    color: AbiliaColors.white,
                                  ),
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
    final Question oldQuestion,
    BuildContext context,
  ) async {
    final authProviders = copiedAuthProviders(context);
    final result = await Navigator.of(context).push<ImageAndName>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: authProviders,
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

  void _handleDeleteQuestion(
    final Question deletedQuestion,
    BuildContext context,
  ) {
    final filteredQuestions =
        checklist.questions.where((q) => q.id != deletedQuestion.id);

    context.read<EditActivityCubit>().replaceActivity(
          activity.copyWith(
            infoItem: checklist.copyWith(questions: filteredQuestions),
          ),
        );
  }

  void _handleReorderQuestion(
    final Question question,
    ChecklistReorderDirection direction,
    BuildContext context,
  ) {
    var questions = checklist.questions.toList();
    final qIndex = questions.indexWhere((q) => q.id == question.id);
    final swapWithIndex =
        direction == ChecklistReorderDirection.up ? qIndex - 1 : qIndex + 1;

    if (qIndex >= 0 &&
        qIndex < questions.length &&
        swapWithIndex >= 0 &&
        swapWithIndex < questions.length) {
      final tmpQ = questions[qIndex];
      questions[qIndex] = questions[swapWithIndex];
      questions[swapWithIndex] = tmpQ;
    }

    context.read<EditActivityCubit>().replaceActivity(
          activity.copyWith(
            infoItem: checklist.copyWith(questions: questions),
          ),
        );
  }

  void _handleNewQuestion(BuildContext context) async {
    final authProviders = copiedAuthProviders(context);
    final result = await Navigator.of(context).push<ImageAndName>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: authProviders,
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
                final authProviders = copiedAuthProviders(context);
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: authProviders,
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
    final authProviders = copiedAuthProviders(context);
    final result = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MultiBlocProvider(
          providers: authProviders,
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
      child: IconActionButtonDark(
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
