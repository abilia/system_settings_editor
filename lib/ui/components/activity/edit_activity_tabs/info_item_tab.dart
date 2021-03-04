import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class InfoItemTab extends StatelessWidget with EditActivityTab {
  InfoItemTab({
    Key key,
    @required this.state,
  }) : super(key: key);

  final EditActivityState state;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final activity = state.activity;
    final infoItem = activity.infoItem;

    Future onTap() async {
      final result = await Navigator.of(context).push<Type>(
        MaterialPageRoute(
          builder: (context) => SelectInfoTypePage(
            infoItemType: activity.infoItem.runtimeType,
          ),
        ),
      );
      if (result != null) {
        BlocProvider.of<EditActivityBloc>(context)
            .add(ChangeInfoItemType(result));
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
  }
}

class EditChecklistWidget extends StatefulWidget {
  final Activity activity;
  final Checklist checklist;
  final GestureTapCallback onTap;

  const EditChecklistWidget({
    Key key,
    @required this.activity,
    @required this.checklist,
    @required this.onTap,
  }) : super(key: key);

  @override
  _EditChecklistWidgetState createState() => _EditChecklistWidgetState();
}

class _EditChecklistWidgetState extends State<EditChecklistWidget> {
  final tempImageFiles = <int, File>{};

  void newFileAdded(File file, int id) =>
      setState(() => tempImageFiles[id] = file);

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
                onTap: widget.onTap,
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
                    selectedChecklist != widget.checklist) {
                  BlocProvider.of<EditActivityBloc>(context).add(
                      ReplaceActivity(widget.activity
                          .copyWith(infoItem: selectedChecklist)));
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
                        widget.checklist,
                        padding:
                            EdgeInsets.fromLTRB(0.0, 12.0.s, 16.0.s, 25.0.s),
                        onTap: _handleEditQuestionResult,
                        tempImageFiles: tempImageFiles,
                        preview: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16.0.s),
                    child: Tts(
                      data: Translator.of(context).translate.addNew,
                      child: RawMaterialButton(
                        constraints: BoxConstraints(minHeight: 48.0.s),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: AbiliaColors.green140),
                          borderRadius: borderRadius,
                        ),
                        fillColor: AbiliaColors.green,
                        elevation: 0.0,
                        disabledElevation: 0.0,
                        focusElevation: 0.0,
                        highlightElevation: 0.0,
                        hoverElevation: 0.0,
                        onPressed: _handleNewQuestion,
                        child: Row(
                          children: [
                            SizedBox(width: 12.0.s),
                            Icon(AbiliaIcons.new_icon, size: smallIconSize),
                            SizedBox(width: 12.0.s),
                            Text(
                              Translator.of(context).translate.addNew,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(height: 1),
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

  void _handleEditQuestionResult(final Question oldQuestion) async {
    final result = await Navigator.of(context).push<QuestionResult>(
      MaterialPageRoute(
        builder: (_) => CopiedAuthProviders(
          blocContext: context,
          child: EditQuestionPage(question: oldQuestion),
        ),
      ),
    );

    if (result != null && result.question != oldQuestion) {
      final questionMap = {for (var q in widget.checklist.questions) q.id: q}
        ..[oldQuestion.id] = result.question;
      final newQuestions = questionMap.values.where((q) => q != null);

      if (result.hasNewImage) {
        newFileAdded(result.newImage, result.question.id);
      }

      BlocProvider.of<EditActivityBloc>(context).add(
        ReplaceActivity(
          widget.activity.copyWith(
            infoItem: widget.checklist.copyWith(questions: newQuestions),
          ),
        ),
      );
    }
  }

  void _handleNewQuestion() async {
    final result = await Navigator.of(context).push<QuestionResult>(
      MaterialPageRoute(
        builder: (_) => CopiedAuthProviders(
          blocContext: context,
          child: EditQuestionPage(),
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      final uniqueId = DateTime.now().millisecondsSinceEpoch;

      if (result.hasNewImage) {
        newFileAdded(result.newImage, uniqueId);
      }

      BlocProvider.of<EditActivityBloc>(context).add(
        ReplaceActivity(
          widget.activity.copyWith(
            infoItem: widget.checklist.copyWith(
              questions: [
                ...widget.checklist.questions,
                result.question.copyWith(id: uniqueId)
              ],
            ),
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
    Key key,
    @required this.activity,
    @required this.infoItem,
    @required this.onTap,
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
                  BlocProvider.of<EditActivityBloc>(context).add(
                    ReplaceActivity(activity.copyWith(
                      infoItem: NoteInfoItem(result),
                    )),
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
                            .copyWith(color: const Color(0xff747474)),
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
        settings: RouteSettings(name: 'EditNotePage'),
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
      BlocProvider.of<EditActivityBloc>(context).add(
        ReplaceActivity(
          activity.copyWith(
            infoItem: NoteInfoItem(result),
          ),
        ),
      );
    }
  }
}

class _LibraryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LibraryButton({Key key, this.onPressed}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.0.s, 4.0.s, 4.0.s, 4.0.s),
      child: ActionButton(
        onPressed: onPressed,
        themeData: darkButtonTheme,
        child: Icon(
          AbiliaIcons.show_text,
          size: defaultIconSize,
          color: AbiliaColors.black,
        ),
      ),
    );
  }
}
