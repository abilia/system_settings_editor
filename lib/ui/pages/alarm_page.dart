import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/i18n/translations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class AlarmPage extends StatelessWidget {
  final Activity activity;
  final bool atStartTime, atEndTime;
  const AlarmPage(
      {Key key,
      @required this.activity,
      this.atStartTime = false,
      this.atEndTime = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline;
    final translate = Translator.of(context).translate;
    return Scaffold(
      key: TestKey.onScreenAlarm,
      appBar: AbiliaAppBar(
        height: 68.0,
        title: translate.alarm,
        hasClose: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            padding24,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TimeText(
                  date: activity.start,
                  active: atStartTime,
                ),
                if (activity.hasEndTime)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child:
                        Text('-', style: Theme.of(context).textTheme.headline),
                  ),
                if (activity.hasEndTime)
                  TimeText(
                    date: activity.end,
                    active: atEndTime,
                  ),
              ],
            ),
            padding24,
            Expanded(
              flex: 48,
              child: Container(
                decoration: BoxDecoration(
                    color: AbiliaColors.white,
                    border: Border.all(
                      color: AbiliaColors.transparantBlack[20],
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      if (activity.title?.isNotEmpty == true)
                        Text(
                          activity.title ?? '',
                          style: textStyle,
                        ),
                      if (activity.fileId?.isNotEmpty == true)
                        SizedBox(height: 32.0),
                      if (activity.fileId?.isNotEmpty == true)
                        Expanded(
                          child: FadeInCalenderImage(
                            imageFileId: activity.fileId,
                            width: 287.0,
                            height: 274.0,
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
            padding32,
          ],
        ),
      ),
      bottomNavigationBar: OkBottomBar(),
    );
  }

  Spacer get padding24 => const Spacer(flex: 3);
  Spacer get padding32 => const Spacer(flex: 4);
}
