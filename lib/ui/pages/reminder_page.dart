import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:intl/intl.dart';

class ReminderPage extends StatelessWidget {
  final Activity activity;
  final int reminderTime;
  const ReminderPage(
      {Key key, @required this.activity, @required this.reminderTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline;
    final translate = Translator.of(context).translate;
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);
    return Scaffold(
      key: TestKey.onScreenAlarm,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(translate.reminder),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: <Widget>[
            padding56,
            Center(
              child: Text(translate.inMinutes(reminderTime),
                  style: Theme.of(context)
                      .textTheme
                      .display2
                      .copyWith(color: AbiliaColors.red)),
            ),
            padding64,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(timeFormat.format(activity.start), style: textStyle),
                if (activity.hasEndTime)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('-', style: textStyle),
                  ),
                if (activity.hasEndTime)
                  Text(timeFormat.format(activity.end), style: textStyle),
              ],
            ),
            padding16,
            Expanded(
              flex: 14,
              child: Container(
                decoration: BoxDecoration(
                    color: AbiliaColors.white,
                    border: Border.all(
                      color: AbiliaColors.transparantBlack[10],
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      if (activity.fileId?.isNotEmpty == true)
                        FadeInCalenderImage(
                          imageFileId: activity.fileId,
                          width: 96.0,
                          height: 96.0,
                        ),
                      if (activity.title?.isNotEmpty == true)
                        Expanded(
                          child: Text(
                            activity.title,
                            style: textStyle,
                            textAlign: TextAlign.center,
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
            padding200,
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FractionallySizedBox(
            widthFactor: 0.55,
            child: FlatButton(
              color: AbiliaColors.green,
              child: Text(
                translate.ok,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: AbiliaColors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    );
  }

  Spacer get padding16 => const Spacer(flex: 2);
  Spacer get padding56 => const Spacer(flex: 7);
  Spacer get padding64 => const Spacer(flex: 8);
  Spacer get padding200 => const Spacer(flex: 25);
}
