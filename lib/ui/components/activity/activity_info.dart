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
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, settingsState) {
        final displayQuarter = settingsState.displayQuarterHour;
        return Row(
          children: <Widget>[
            if (displayQuarter) ActivityInfoSideDots(activityDay),
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(
                  left: displayQuarter ? 0 : ActivityInfo.margin),
              child: ActivityInfo(activityDay),
            )),
          ],
        );
      },
    );
  }
}

class ActivityInfo extends StatelessWidget with Checker {
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
    final signedOff = activityDay.isSignedOff;
    final theme = signedOff
        ? Theme.of(context).copyWith(
            buttonTheme: uncheckButtonThemeData,
            buttonColor: AbiliaColors.transparentBlack20,
          )
        : Theme.of(context).copyWith(
            buttonTheme: checkButtonThemeData,
            buttonColor: AbiliaColors.green,
          );
    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) => AnimatedTheme(
        duration: animationDuration,
        data: theme.copyWith(
            cardColor: activityDay.end.occasion(now) == Occasion.past
                ? AbiliaColors.white110
                : AbiliaColors.white),
        child: Column(
          children: <Widget>[
            TimeRow(activityDay),
            Expanded(
              child: Container(
                decoration: boxDecoration,
                child: ActivityContainer(activityDay: activityDay),
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
                  onPressed: () async {
                    await checkConfirmation(
                      context,
                      now,
                      activityDay,
                      overlayStyle: true,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

mixin Checker {
  Future checkConfirmation(
    BuildContext context,
    DateTime now,
    ActivityDay activityDay, {
    String extraMessage,
    bool overlayStyle = false,
  }) async {
    final translate = Translator.of(context).translate;
    final shouldCheck = await showViewDialog<bool>(
      context: context,
      builder: (_) => ConfirmActivityActionDialog(
        activityOccasion: activityDay.toOccasion(now),
        title: activityDay.isSignedOff
            ? translate.unCheckActivityQuestion
            : translate.checkActivityQuestion,
        extraMessage: extraMessage,
        overlayStyle: overlayStyle,
      ),
    );
    if (shouldCheck == true) {
      BlocProvider.of<ActivitiesBloc>(context)
          .add(UpdateActivity(activityDay.activity.signOff(activityDay.day)));
    }
  }
}

class ActivityContainer extends StatelessWidget {
  const ActivityContainer({
    Key key,
    @required this.activityDay,
  }) : super(key: key);

  final ActivityDay activityDay;

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final hasImage = activity.hasImage;
    final hasAttachment = activity.hasAttachment;
    final hasTopInfo = !(hasImage && !hasAttachment && !activity.hasTitle);
    return Container(
      decoration: BoxDecoration(
        color: activityDay.isSignedOff
            ? inactiveGrey
            : Theme.of(context).cardColor,
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
                child: TopInfo(activityDay: activityDay),
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
                    child: Attachment(activityDay: activityDay),
                  ),
                ],
              ),
            ),
          if ((hasImage || activityDay.isSignedOff) && !hasAttachment)
            Flexible(
              flex: activity.checkable ? 236 : 298,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: CheckedImageWithImagePopup(
                    activityDay: activityDay,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class Attachment extends StatelessWidget with Checker {
  static const padding = EdgeInsets.fromLTRB(18.0, 10.0, 14.0, 24.0);
  final ActivityDay activityDay;
  const Attachment({
    Key key,
    @required this.activityDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final activity = activityDay.activity;
    final item = activity.infoItem;
    if (item is NoteInfoItem) {
      return NoteBlock(
        text: item.text,
        textWidget: Text(item.text),
      );
    } else if (item is Checklist) {
      return CheckListView(
        item,
        day: activityDay.day,
        padding: Attachment.padding.subtract(QuestionView.padding),
        onTap: (question) async {
          final signedOff = item.signOff(question, activityDay.day);
          final updatedActivity = activity.copyWith(
            infoItem: signedOff,
          );
          BlocProvider.of<ActivitiesBloc>(context).add(
            UpdateActivity(updatedActivity),
          );

          if (signedOff.allSignedOff(activityDay.day) &&
              updatedActivity.checkable &&
              !activityDay.isSignedOff) {
            await checkConfirmation(
              context,
              DateTime.now(),
              ActivityDay(updatedActivity, activityDay.day),
              extraMessage: translate.checklistDoneInfo,
            );
          }
        },
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
    return Tts(
      data: text,
      child: Container(
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
      ),
    );
  }
}

class TopInfo extends StatelessWidget {
  const TopInfo({
    Key key,
    @required this.activityDay,
  }) : super(key: key);

  final ActivityDay activityDay;

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final hasImage = activity.hasImage;
    final hasTitle = activity.hasTitle;
    final hasAttachment = activity.hasAttachment;
    final imageBelow = hasImage && hasAttachment && !hasTitle;
    final signedOff = activityDay.isSignedOff;
    final themeData = Theme.of(context);
    final imageToTheLeft = (hasImage || signedOff) && hasAttachment && hasTitle;

    final checkableImage = CheckedImageWithImagePopup(
      activityDay: activityDay,
      size: 96,
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
                  child: Tts(
                    child: Text(
                      activity.title,
                      style: themeData.textTheme.headline5,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                    ),
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
