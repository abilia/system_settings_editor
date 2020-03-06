import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final double cardMargin;
  static const double cardPadding = 4.0;
  static const double imageSize = 48.0;

  const ActivityCard({Key key, this.activityOccasion, this.cardMargin = 0})
      : assert(activityOccasion != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occasion = activityOccasion.occasion;
    final activity = activityOccasion.activity;
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);
    final hasImage = activity.hasImage;
    final hasTitle = activity.title?.isNotEmpty == true;
    final signedOff = activity.isSignedOff(activityOccasion.day);
    final current = occasion == Occasion.current;
    final inactive = occasion == Occasion.past || signedOff;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: cardMargin),
      child: Stack(
        overflow: Overflow.visible,
        children: [
          InkWell(
            borderRadius: borderRadius,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (innerContext) => MultiBlocProvider(
                    providers: [
                      BlocProvider<ClockBloc>.value(
                        value: BlocProvider.of<ClockBloc>(context),
                      ),
                      BlocProvider<ActivitiesBloc>.value(
                        value: BlocProvider.of<ActivitiesBloc>(context),
                      ),
                    ],
                    child: ActivityPage(occasion: activityOccasion),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                    color: current
                        ? AbiliaColors.red
                        : AbiliaColors.transparantBlack[5]),
              ),
              child: AnimatedOpacity(
                opacity: inactive ? .5 : 1,
                duration: const Duration(seconds: 1),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: theme.cardColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(cardPadding),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            if (signedOff)
                              SizedBox(width: imageSize + cardPadding),
                            if (hasImage)
                              Hero(
                                tag: activity.id,
                                child: FadeInCalendarImage(
                                  imageFileId: activity.fileId,
                                  imageFilePath: activity.icon,
                                  width: imageSize,
                                  height: imageSize,
                                ),
                              ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: cardPadding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    if (hasTitle)
                                      Text(
                                        activity.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.subhead.copyWith(
                                            color: AbiliaColors.black),
                                      ),
                                    Text(
                                      activity.fullDay
                                          ? Translator.of(context)
                                              .translate
                                              .fullDay
                                          : activity.hasEndTime
                                              ? '${timeFormat.format(activity.start)} - ${timeFormat.format(activity.end)}'
                                              : '${timeFormat.format(activity.start)}',
                                      style: theme.textTheme.body2.copyWith(
                                        color: AbiliaColors.black[75],
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: buildInfoIcons(activity),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (current) buildNowBanner(context),
          if (signedOff)
            Icon(
              AbiliaIcons.check_button,
              size: 64,
              color: AbiliaColors.green,
            ),
        ],
      ),
    );
  }

  Widget buildNowBanner(BuildContext context) => Positioned(
        right: -4.0,
        top: -cardMargin,
        child: Container(
          height: 24.0,
          width: 59.0,
          decoration: BoxDecoration(
            color: AbiliaColors.red,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Text(
              Translator.of(context).translate.now,
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: AbiliaColors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

  Widget buildInfoIcons(Activity activity) {
    return Row(
      children: <Widget>[
        if (!activity.fullDay)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              activity.alarm.iconData(),
              size: 18,
            ),
          ),
        if (!activity.fullDay && activity.reminderBefore.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              AbiliaIcons.handi_reminder,
              size: 18,
            ),
          ),
        if (activity.infoItem != null)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(
              AbiliaIcons.handi_info,
              size: 18,
            ),
          ),
      ],
    );
  }
}
