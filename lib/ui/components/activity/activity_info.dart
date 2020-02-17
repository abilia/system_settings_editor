import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class ActivityInfo extends StatelessWidget {
  final Activity givenActivity;
  final DateTime day;
  const ActivityInfo({
    Key key,
    @required this.givenActivity,
    @required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesBloc, ActivitiesState>(
      builder: (context, activitiesState) {
        return _ActivityInfo(
          activity: (activitiesState is ActivitiesLoaded)
              ? activitiesState.activities.firstWhere(
                  (a) => a.id == givenActivity.id,
                  orElse: () => givenActivity)
              : givenActivity,
          day: day,
        );
      },
    );
  }
}

class _ActivityInfo extends StatelessWidget {
  final Activity activity;
  final DateTime day;
  final animationDuration = const Duration(milliseconds: 500);

  const _ActivityInfo({
    Key key,
    @required this.activity,
    @required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    final hasImage = activity.fileId?.isNotEmpty ?? false;
    final hasAttachment = activity.infoItem?.isNotEmpty ?? false;
    final signedOff = activity.isSignedOff(day);
    return AnimatedTheme(
      duration: animationDuration,
      data: signedOff
          ? Theme.of(context).copyWith(
              buttonTheme: uncheckButtonThemeData,
              buttonColor: AbiliaColors.transparantBlack[20])
          : Theme.of(context).copyWith(
              buttonTheme: checkButtonThemeData,
              buttonColor: AbiliaColors.green),
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: AbiliaColors.transparantBlack[5]),
            ),
            child: AnimatedOpacity(
              duration: animationDuration,
              opacity: signedOff ? .5 : 1,
              child: Container(
                decoration: BoxDecoration(
                    color: AbiliaColors.white, borderRadius: borderRadius),
                constraints: BoxConstraints.expand(),
                child: Column(
                  children: <Widget>[
                    Flexible(
                      flex: 5,
                      child: TopInfo(activity: activity),
                    ),
                    if (hasAttachment)
                      Flexible(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Container(
                            child: Center(
                              child: Text('Attachment'),
                            ),
                            decoration: BoxDecoration(
                                color: AbiliaColors.white[110],
                                borderRadius: BorderRadius.all(
                                  const Radius.circular(12.0),
                                )),
                          ),
                        ),
                      ),
                    if (hasImage && !hasAttachment)
                      Flexible(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Hero(
                            tag: activity.id,
                            child: FadeInCalenderImage(
                              imageFileId: activity.fileId,
                              width: 327.0,
                              height: 289.0,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
          if (activity.checkable)
            CheckButton(
              iconData: signedOff
                  ? AbiliaIcons.close_program
                  : AbiliaIcons.check_button,
              text: signedOff ? translate.uncheck : translate.check,
              onPressed: () {
                BlocProvider.of<ActivitiesBloc>(context)
                    .add(UpdateActivity(activity.signOff(day)));
              },
            ),
          AnimatedOpacity(
            opacity: signedOff ? 1.0 : 0.0,
            duration: animationDuration,
            child: Center(
              child: Icon(
                AbiliaIcons.check_button,
                size: 328,
                color: AbiliaColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;
  final String text;

  const CheckButton({Key key, this.onPressed, this.iconData, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      top: -8,
      right: -8,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: borderRadius,
        ),
        child: FlatButton.icon(
          icon: Icon(iconData),
          label: Text(text, style: theme.textTheme.body2),
          color: theme.buttonColor,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class TopInfo extends StatelessWidget {
  const TopInfo({
    Key key,
    @required this.activity,
  }) : super(key: key);

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final hasImage = activity.fileId?.isNotEmpty ?? false;
    final hasAttachment = activity.infoItem?.isNotEmpty ?? false;
    final hasTitle = activity.title?.isNotEmpty ?? false;
    final imageToTheLeft = hasImage && hasAttachment && hasTitle;
    final imageBelow = hasImage && hasAttachment && !hasTitle;
    final themeData = Theme.of(context);
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);

    return Row(
      mainAxisAlignment:
          imageToTheLeft ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: <Widget>[
        if (imageToTheLeft)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: FadeInCalenderImage(
              imageFileId: activity.fileId,
              height: 109,
              width: 109,
            ),
          ),
        Column(
          crossAxisAlignment: imageToTheLeft
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          mainAxisAlignment:
              imageBelow ? MainAxisAlignment.end : MainAxisAlignment.center,
          children: <Widget>[
            if (activity.title?.isNotEmpty ?? false)
              Text(
                activity.title,
                style: themeData.textTheme.headline,
              ),
            Text(
              activity.fullDay
                  ? Translator.of(context).translate.fullDay
                  : activity.hasEndTime
                      ? '${timeFormat.format(activity.start)} - ${timeFormat.format(activity.end)}'
                      : '${timeFormat.format(activity.start)}',
              style: themeData.textTheme.subhead.copyWith(
                color: AbiliaColors.black,
              ),
            ),
            if (imageBelow)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FadeInCalenderImage(
                  imageFileId: activity.fileId,
                  height: 109,
                  width: 109,
                ),
              )
          ],
        ),
      ],
    );
  }
}
