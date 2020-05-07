import 'package:flutter/material.dart';
import 'package:seagull/models/info_item.dart';
import 'package:seagull/ui/components/all.dart';

class CheckListView extends StatefulWidget {
  final Checklist checklist;

  const CheckListView(this.checklist, {Key key}) : super(key: key);

  @override
  _CheckListViewState createState() => _CheckListViewState(ScrollController());
}

class _CheckListViewState extends State<CheckListView> {
  final ScrollController controller;

  _CheckListViewState(this.controller);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scrollbar(
          child: ListView.builder(
            controller: controller,
            padding: Attachment.padding,
            itemCount: widget.checklist.questions.length,
            itemBuilder: (context, i) =>
                QuestionView(widget.checklist.questions[i]),
          ),
        ),
        ArrowUp(controller: controller),
        ArrowDown(controller: controller),
      ],
    );
  }
}

class QuestionView extends StatelessWidget {
  final Question question;

  const QuestionView(this.question, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        question.name,
        textScaleFactor: 2,
      ),
    );
  }
}
