import 'package:flutter/material.dart';
import 'package:seagull/models/info_item.dart';
import 'package:seagull/ui/components/all.dart';

class CheckListView extends StatelessWidget {
  final Checklist checklist;

  const CheckListView(this.checklist, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
        padding: Attachment.padding,
        itemCount: checklist.questions.length,
        itemBuilder: (context, i) => QuestionView(checklist.questions[i]),
      ),
    );
  }
}

class QuestionView extends StatelessWidget {
  final Question question;

  const QuestionView(this.question, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(question.name);
  }
}
