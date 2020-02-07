import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final double cardMargin;

  const ActivityCard({Key key, this.activityOccasion, this.cardMargin})
      : assert(activityOccasion != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final occasion = activityOccasion.occasion;
    final activity = activityOccasion.activity;
    final theme = pickTheme(context: context, occasion: occasion);
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);
    final hasImage = activity.fileId != null;
    final current = activityOccasion.occasion == Occasion.current;
    return Theme(
      data: theme,
      child: Stack(
        overflow: Overflow.visible,
        children: [
          AnimatedOpacity(
            opacity: activityOccasion.occasion == Occasion.past ? .4 : 1,
            duration: const Duration(seconds: 1),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: cardMargin),
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                    color: current
                        ? AbiliaColors.red
                        : AbiliaColors.transparantBlack[5]),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: theme.cardColor,
                ),
                child: InkWell(
                  borderRadius: borderRadius,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ActivityPage(occasion: activityOccasion),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                    child: Row(
                      children: <Widget>[
                        hasImage
                            ? Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: FadeInThumb(
                                  imageFileId: activity.fileId,
                                  width: 48,
                                  height: 48,
                                ),
                              )
                            : SizedBox(height: 48),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  activity.title ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subhead
                                      .copyWith(color: AbiliaColors.black),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                        activity.fullDay
                                            ? Translator.of(context)
                                                .translate
                                                .fullDay
                                            : activity.hasEndTime
                                                ? '${timeFormat.format(activity.start)} - ${timeFormat.format(activity.end)}'
                                                : '${timeFormat.format(activity.start)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                                color: AbiliaColors.black[75],
                                                height: 1.4)),
                                    Row(
                                      children: <Widget>[
                                        if (!activity.fullDay)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4.0),
                                            child: Icon(
                                              iconDataFor(activity.alarm),
                                              size: 18,
                                            ),
                                          ),
                                        if (!activity.fullDay &&
                                            activity.reminderBefore.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4.0),
                                            child: Icon(
                                              AbiliaIcons.handi_reminder,
                                              size: 18,
                                            ),
                                          ),
                                        if (activity.infoItem != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4.0),
                                            child: Icon(
                                              AbiliaIcons.handi_info,
                                              size: 18,
                                            ),
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (current) Positioned(right: -3, child: NowBanner())
        ],
      ),
    );
  }

  IconData iconDataFor(AlarmType alarm) {
    if (alarm.sound) return AbiliaIcons.handi_alarm_vibration;
    if (alarm.vibrate) return AbiliaIcons.handi_vibration;
    return AbiliaIcons.handi_no_alarm_vibration;
  }

  ThemeData pickTheme({BuildContext context, Occasion occasion}) {
    final theme = Theme.of(context);
    switch (occasion) {
      case Occasion.past:
        return theme.copyWith(
            cardColor: AbiliaColors.transparantWhite[50],
            textTheme: theme.textTheme.copyWith(
                subhead: theme.textTheme.subtitle.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AbiliaColors.black[75]),
                body2: theme.textTheme.body1
                    .copyWith(decoration: TextDecoration.lineThrough)));
      case Occasion.current:
      case Occasion.future:
      default:
        return theme;
    }
  }
}
