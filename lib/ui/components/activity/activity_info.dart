import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
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

class ActivityInfo extends StatefulWidget {
  static const margin = 12.0;
  final ActivityDay activityDay;
  final Widget previewImage;
  final bool checkButton;
  ActivityInfo(
    this.activityDay, {
    Key key,
    this.previewImage,
    this.checkButton = true,
  }) : super(key: key);
  factory ActivityInfo.from({Activity activity, DateTime day, Key key}) =>
      ActivityInfo(ActivityDay(activity, day), key: key);

  static const animationDuration = Duration(milliseconds: 500);

  @override
  _ActivityInfoState createState() => _ActivityInfoState();
}

class _ActivityInfoState extends State<ActivityInfo> with Checker {
  Activity get activity => widget.activityDay.activity;

  DateTime get day => widget.activityDay.day;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final signedOff = widget.activityDay.isSignedOff;
    final theme = signedOff
        ? Theme.of(context).copyWith(
            buttonTheme: uncheckButtonThemeData,
            buttonColor: AbiliaColors.transparentBlack20,
          )
        : Theme.of(context).copyWith(
            buttonTheme: checkButtonThemeData,
            buttonColor: AbiliaColors.green,
          );
    return BlocBuilder<ClockBloc, DateTime>(builder: (context, now) {
      final occasion = widget.activityDay.toOccasion(now);
      return AnimatedTheme(
        duration: ActivityInfo.animationDuration,
        data: theme.copyWith(
            cardColor: widget.activityDay.end.occasion(now) == Occasion.past
                ? AbiliaColors.white110
                : AbiliaColors.white),
        child: Column(
          children: <Widget>[
            TimeRow(widget.activityDay),
            Expanded(
              child: Container(
                decoration: boxDecoration,
                child: ActivityContainer(
                  activityDay: widget.activityDay,
                  previewImage: widget.previewImage,
                ),
              ),
            ),
            if (activity.checkable &&
                !occasion.isSignedOff &&
                widget.checkButton)
              Padding(
                padding: const EdgeInsets.only(top: 7.0),
                child: CheckButton(
                  key: TestKey.activityCheckButton,
                  iconData: AbiliaIcons.handi_check,
                  text: translate.check,
                  onPressed: () async {
                    await checkConfirmation(
                      context,
                      occasion,
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}

mixin Checker {
  Future<bool> checkConfirmation(
    BuildContext context,
    ActivityOccasion activityOccasion, {
    String message,
  }) async {
    final check = await showViewDialog<bool>(
      context: context,
      builder: (_) => CheckActivityConfirmDialog(
        activityOccasion: activityOccasion,
        message: message,
      ),
    );
    if (check == true) {
      BlocProvider.of<ActivitiesBloc>(context).add(UpdateActivity(
          activityOccasion.activity.signOff(activityOccasion.day)));
    }
    return check;
  }
}

class ActivityContainer extends StatelessWidget {
  const ActivityContainer({
    Key key,
    @required this.activityDay,
    this.previewImage,
  }) : super(key: key);

  final ActivityDay activityDay;
  final Widget previewImage;

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final hasImage = activity.hasImage || previewImage != null;
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
                  const Divider(
                    height: 1,
                    endIndent: 0.0,
                  ),
                  Expanded(
                    child: Attachment(
                      activityDay: activityDay,
                    ),
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
                  child: previewImage ??
                      CheckedImageWithImagePopup(
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
      return ChecklistView(
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
              ActivityDay(updatedActivity, activityDay.day)
                  .toOccasion(DateTime.now()),
              message: translate.checklistDoneInfo,
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

  const CheckButton({
    Key key,
    this.onPressed,
    this.iconData,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = greenButtonTheme;
    return Tts(
      data: text,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: borderRadius,
        ),
        child: FlatButton.icon(
          icon: IconTheme(
            data: theme.iconTheme,
            child: Icon(iconData),
          ),
          label: Text(
            text,
            style: theme.textTheme.button,
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
      size: hugeIconSize,
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
