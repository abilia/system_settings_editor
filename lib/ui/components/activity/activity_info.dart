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

class ActivityInfo extends StatelessWidget {
  final Activity activity;
  final DateTime day;
  const ActivityInfo({
    Key key,
    @required this.activity,
    @required this.day,
  }) : super(key: key);

  final animationDuration = const Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final signedOff = activity.isSignedOff(day);

    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, now) => AnimatedTheme(
        duration: animationDuration,
        data: activity.endClock(day).occasion(now) == Occasion.past || signedOff
            ? Theme.of(context).copyWith(
                buttonTheme: uncheckButtonThemeData,
                buttonColor: AbiliaColors.transparentBlack[20],
                cardColor: AbiliaColors.white[110],
              )
            : Theme.of(context).copyWith(
                buttonTheme: checkButtonThemeData,
                buttonColor: AbiliaColors.green,
                cardColor: AbiliaColors.white,
              ),
        child: Column(
          children: <Widget>[
            if (activity.fullDay)
              Text(translate.fullDay)
            else
              ActivityTimeRange(activity: activity, day: day),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(color: AbiliaColors.transparentBlack[5]),
                ),
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
    final hasAttachment = activity.infoItem?.isNotEmpty ?? false;
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
                padding: EdgeInsets.fromLTRB(
                    12, 12, 12, hasAttachment || hasImage ? 12.0 : 0.0),
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
                    color: AbiliaColors.white[120],
                    indent: 12.0,
                    height: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return SingleChildScrollView(
                          child: Attachment(
                            infoItem: InfoItem.fromBase64(activity.infoItem),
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          if ((hasImage || signedOff) && !hasAttachment)
            Flexible(
              flex: activity.checkable ? 236 : 298,
              child: Center(
                child: CheckMarkWrapper(
                  checked: signedOff,
                  child: hasImage
                      ? FadeInCalendarImage(
                          imageFileId: activity.fileId,
                          imageFilePath: activity.icon,
                          activityId: activity.id,
                          width: 327.0,
                          height: 289.0,
                        )
                      : SizedBox(
                          height: 289,
                          width: 327,
                        ),
                  small: false,
                ),
              ),
            )
        ],
      ),
    );
  }
}

class Attachment extends StatelessWidget {
  final InfoItem infoItem;
  final double height;
  final double width;
  const Attachment({
    Key key,
    @required this.infoItem,
    @required this.height,
    @required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = infoItem?.type == InfoItemType.NOTE
        ? NoteBlock(
            text: (infoItem.infoItemData as NoteData).text,
            height: this.height,
            width: width,
          )
        : Text('No note...');
    return Container(
      child: info,
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
          style: theme.textTheme.body2.copyWith(height: 1),
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
    final hasAttachment = activity.infoItem?.isNotEmpty ?? false;
    final hasTitle = activity.title?.isNotEmpty ?? false;
    final imageBelow = hasImage && hasAttachment && !hasTitle;
    final signedOff = activity.isSignedOff(day);
    final themeData = Theme.of(context);
    final imageToTheLeft = (hasImage || signedOff) && hasAttachment && hasTitle;

    final checkableImage = CheckMarkWrapper(
      checked: signedOff,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: hasImage
            ? FadeInCalendarImage(
                imageFileId: activity.fileId,
                imageFilePath: activity.icon,
                activityId: activity.id,
                height: 96,
                width: 96,
              )
            : SizedBox(
                height: 96,
                width: 96,
              ),
      ),
    );

    return Row(
      mainAxisAlignment:
          imageToTheLeft ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: <Widget>[
        if (imageToTheLeft)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
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
                    style: themeData.textTheme.headline,
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
