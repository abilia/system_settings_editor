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
  final DateTime day;
  const SelectReminderDialog({
    Key key,
    @required this.activity,
    @required this.day,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = abiliaTheme;
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) {
        final sameReminders = eq(activity.reminders, state.activity.reminders);
        return ViewDialog(
          onOk: !sameReminders
              ? () async {
                  final editActivityBloc =
                      BlocProvider.of<EditActivityBloc>(context);
                  await Navigator.of(context).maybePop(true);
                  if (activity.isRecurring) {
                    final applyTo = await showViewDialog<ApplyTo>(
                      context: context,
                      builder: (context) => EditRecurrentDialog(),
                    );
                    if (applyTo == null) return;
                    editActivityBloc.add(SaveRecurringActivity(applyTo, day));
                  } else {
                    editActivityBloc.add(SaveActivity());
                  }
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
