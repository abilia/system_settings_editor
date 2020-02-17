import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

class ReminderPage extends StatelessWidget {
  final Activity activity;
  final DateTime day;
  final int reminderTime;
  const ReminderPage({
    Key key,
    @required this.activity,
    @required this.day,
    @required this.reminderTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      key: TestKey.onScreenReminder,
      appBar: AbiliaAppBar(title: translate.reminder),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 30),
                child: Text(
                  translate.inMinutes(reminderTime),
                  style: Theme.of(context)
                      .textTheme
                      .display1
                      .copyWith(color: AbiliaColors.red),
                ),
              ),
            ),
            Expanded(
              child: ActivityInfo(
                givenActivity: activity,
                day: day,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
