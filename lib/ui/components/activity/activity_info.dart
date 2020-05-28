import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/models/info_item.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

class ActivityInfoWithDots extends StatelessWidget {
  final ActivityDay activityDay;

  const ActivityInfoWithDots(this.activityDay, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ActivityInfoSideDots(activityDay),
        Expanded(child: ActivityInfo(activityDay)),
      ],
    );
  }
}

class ActivityInfo extends StatelessWidget {
  static const margin = 12.0;
  final ActivityDay activityDay;
  Activity get activity => activityDay.activity;
  DateTime get day => activityDay.day;
  const ActivityInfo(this.activityDay, {Key key}) : super(key: key);
  factory ActivityInfo.from({Activity activity, DateTime day, Key key}) =>
      ActivityInfo(ActivityDay(activity, day), key: key);

  static const animationDuration = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final signedOff = activity.isSignedOff(day);
    final theme = signedOff
        ? Theme.of(context).copyWith(
            buttonTheme: uncheckButtonThemeData,
            buttonColor: AbiliaColors.transparentBlack20,
          )
        : Theme.of(context).copyWith(
            buttonTheme: checkButtonThemeData,
            buttonColor: AbiliaColors.green,
          );
    final ad = ActivityDay(activity, day);
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) => AnimatedTheme(
        duration: animationDuration,
        data: theme.copyWith(
            cardColor: ad.end.occasion(now) == Occasion.past
                ? AbiliaColors.white110
                : AbiliaColors.white),
        child: Column(
          children: <Widget>[
            TimeRow(ad),
            Expanded(
              child: Container(
                decoration: borderDecoration,
                child: ActivityContainer(
                    activity: activity, day: day, signedOff: signedOff),
              ),
            ),
            if (activity.checkable)
              Padding(
                padding: const EdgeInsets.only(top: 7.0),
                child: CheckButton(
                  key: signedOff
                      ? TestKey.activityUncheckButton
                      : TestKey.activityCheckButton,
                  iconData: signedOff
                      ? AbiliaIcons.close_program
                      : AbiliaIcons.handi_check,
                  text: signedOff ? translate.uncheck : translate.check,
                  onPressed: () {
                    BlocProvider.of<ActivitiesBloc>(context)
                        .add(UpdateActivity(activity.signOff(day)));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ActivityContainer extends StatelessWidget {
  const ActivityContainer({
    Key key,
    @required this.activity,
    @required this.day,
    @required this.signedOff,
  }) : super(key: key);

  final Activity activity;
  final DateTime day;
  final bool signedOff;

  @override
  Widget build(BuildContext context) {
    final hasImage = activity.hasImage;
    final hasAttachment = activity.hasAttachment;
    final hasTopInfo = !(hasImage && !hasAttachment && activity.title.isEmpty);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: borderRadius,
      ),
      constraints: BoxConstraints.expand(),
      child: Column(
        children: <Widget>[
          if (hasTopInfo)
            Flexible(
              flex: 126,
              child: Padding(
                padding: EdgeInsets.all(ActivityInfo.margin).subtract(
                  EdgeInsets.only(
                    bottom: hasAttachment || hasImage ? 0 : ActivityInfo.margin,
                  ),
                ),
                child: TopInfo(
                  activity: activity,
                  day: day,
                ),
              ),
            ),
          if (hasAttachment)
            Flexible(
              key: TestKey.attachment,
              flex: activity.checkable ? 236 : 298,
              child: Column(
                children: <Widget>[
                  Divider(
                    color: AbiliaColors.white120,
                    indent: ActivityInfo.margin,
                    height: 1,
                  ),
                  Expanded(
                    child: Attachment(
                      activity: activity,
                      day: day,
                    ),
                  ),
                ],
              ),
            ),
          if ((hasImage || signedOff) && !hasAttachment)
            Flexible(
              flex: activity.checkable ? 236 : 298,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: CheckedImage(
                    activity: activity,
                    day: day,
                    imageSize: ImageSize.ORIGINAL,
                    fit: BoxFit.contain,
                    small: false,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class Attachment extends StatelessWidget {
  static const padding = EdgeInsets.fromLTRB(18.0, 10.0, 14.0, 24.0);
  final Activity activity;
  final DateTime day;
  const Attachment({
    Key key,
    @required this.activity,
    @required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final item = activity.infoItem;
    if (item is NoteInfoItem) {
      return NoteBlock(text: item.text);
    } else if (item is Checklist) {
      return CheckListView(
        item,
        day: day,
        onTap: (question, day) => BlocProvider.of<ActivitiesBloc>(context).add(
            UpdateActivity(
                activity.copyWith(infoItem: item.signOff(question, day)))),
      );
    }
    return Container();
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
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: borderRadius,
      ),
      child: FlatButton.icon(
        icon: Icon(iconData),
        label: Text(
          text,
          style: theme.textTheme.bodyText1.copyWith(height: 1),
        ),
        color: theme.buttonColor,
        onPressed: onPressed,
      ),
    );
  }
}

class TopInfo extends StatelessWidget {
  const TopInfo({
    Key key,
    @required this.activity,
    @required this.day,
  }) : super(key: key);

  final Activity activity;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final hasImage = activity.hasImage;
    final hasTitle = activity.hasTitle;
    final hasAttachment = activity.hasAttachment;
    final imageBelow = hasImage && hasAttachment && !hasTitle;
    final signedOff = activity.isSignedOff(day);
    final themeData = Theme.of(context);
    final imageToTheLeft = (hasImage || signedOff) && hasAttachment && hasTitle;

    final checkableImage = CheckedImage(
      activity: activity,
      size: 96,
      day: day,
    );

    return Row(
      mainAxisAlignment:
          imageToTheLeft ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: <Widget>[
        if (imageToTheLeft)
          Padding(
            padding: const EdgeInsets.only(right: ActivityInfo.margin),
            child: checkableImage,
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:
                imageBelow ? MainAxisAlignment.end : MainAxisAlignment.center,
            children: <Widget>[
              if (hasTitle)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    activity.title,
                    style: themeData.textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (imageBelow) checkableImage,
            ],
          ),
        ),
      ],
    );
  }
}
