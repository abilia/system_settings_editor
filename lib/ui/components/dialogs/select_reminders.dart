import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:collection/collection.dart';

class SelectReminderDialog extends StatelessWidget {
  static Function eq = const DeepCollectionEquality().equals;
  final Activity activity;
  const SelectReminderDialog({Key key, @required this.activity})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = abiliaTheme;
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) {
        final sameReminders = eq(activity.reminders, state.activity.reminders);
        return ViewDialog(
          onOk: !sameReminders
              ? () {
                  BlocProvider.of<EditActivityBloc>(context)
                      .add(SaveActivity());
                  Navigator.of(context).maybePop(true);
                }
              : null,
          heading: Text(Translator.of(context).translate.reminder,
              style: theme.textTheme.title),
          child: Column(
            children: <Widget>[
              ReminderSwitch(activity: state.activity),
              SizedBox(height: 8.0),
              Reminders(activity: state.activity),
            ],
          ),
        );
      },
    );
  }
}
