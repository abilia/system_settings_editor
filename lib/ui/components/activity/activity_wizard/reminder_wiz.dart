import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/activities/edit_activity/edit_activity_bloc.dart';
import 'package:seagull/ui/all.dart';

class RemindersWiz extends StatelessWidget {
  const RemindersWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) => WizardScaffold(
        iconData: AbiliaIcons.handiReminder,
        title: translate.reminders,
        body: Padding(
          padding: EdgeInsets.fromLTRB(12.0.s, 24.0.s, 16.0.s, 0),
          child: Reminders(
            activity: state.activity,
            expanded: true,
          ),
        ),
      ),
    );
  }
}
