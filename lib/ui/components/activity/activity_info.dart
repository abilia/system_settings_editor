import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ActivityInfoWithDots extends StatelessWidget {
  final ActivityDay activityDay;
  final Widget? previewImage;

  const ActivityInfoWithDots(
    this.activityDay, {
    Key? key,
    this.previewImage,
  }) : super(key: key);

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
              child: ActivityInfo(
                activityDay,
                previewImage: previewImage,
              ),
            )),
          ],
        );
      },
    );
  }
}

class ActivityInfo extends StatefulWidget {
  static final margin = 12.0.s;
  final ActivityDay activityDay;
  final Widget? previewImage;
  final NotificationAlarm? alarm;
  const ActivityInfo(
    this.activityDay, {
    Key? key,
    this.previewImage,
    this.alarm,
  }) : super(key: key);
  factory ActivityInfo.from({
    required Activity activity,
    required DateTime day,
    Key? key,
  }) =>
      ActivityInfo(ActivityDay(activity, day), key: key);

  static const animationDuration = Duration(milliseconds: 500);

  @override
  _ActivityInfoState createState() => _ActivityInfoState();
}

class _ActivityInfoState extends State<ActivityInfo> with ActivityMixin {
  Activity get activity => widget.activityDay.activity;

  DateTime get day => widget.activityDay.day;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockBloc, DateTime>(builder: (context, now) {
      final occasion = widget.activityDay.toOccasion(now);
      return Column(
        children: <Widget>[
          ActivityTopInfo(
            widget.activityDay,
            alarm: widget.alarm,
          ),
          Expanded(
            child: Container(
              decoration: boxDecoration,
              child: ActivityContainer(
                activityDay: widget.activityDay,
                previewImage: widget.previewImage,
                alarm: widget.alarm,
              ),
            ),
          ),
          if (widget.alarm == null &&
              activity.checkable &&
              !occasion.isSignedOff)
            Padding(
              padding: EdgeInsets.only(top: 7.0.s),
              child: CheckButton(
                onPressed: () async {
                  await checkConfirmation(
                    context,
                    occasion,
                  );
                },
              ),
            ),
        ],
      );
    });
  }
}

mixin ActivityMixin {
  static final _log = Logger((ActivityMixin).toString());
  Future<bool?> checkConfirmation(
    BuildContext context,
    ActivityOccasion activityOccasion, {
    String? message,
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

  Future popAlarm(BuildContext context, NotificationAlarm alarm) async {
    _log.fine('pop Alarm: $alarm');
    if (!await Navigator.of(context).maybePop()) {
      _log.info('Could not pop (root?) will -> SystemNavigator.pop');
      await SystemNavigator.pop();
    }
  }
}

class ActivityContainer extends StatelessWidget {
  const ActivityContainer({
    Key? key,
    required this.activityDay,
    this.alarm,
    this.previewImage,
  }) : super(key: key);

  final ActivityDay activityDay;
  final Widget? previewImage;
  final NotificationAlarm? alarm;

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
                      alarm: alarm,
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
                  padding: EdgeInsets.fromLTRB(12.s, 0, 12.s, 12.s),
                  child: previewImage ??
                      CheckedImageWithImagePopup(
                        size: double.infinity,
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

class Attachment extends StatelessWidget with ActivityMixin {
  static final padding = EdgeInsets.fromLTRB(18.0.s, 10.0.s, 14.0.s, 24.0.s);
  final ActivityDay activityDay;
  final NotificationAlarm? alarm;

  const Attachment({
    Key? key,
    required this.activityDay,
    this.alarm,
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
            final checked = await checkConfirmation(
              context,
              ActivityDay(updatedActivity, activityDay.day)
                  .toOccasion(DateTime.now()),
              message: translate.checklistDoneInfo,
            );
            final a = alarm;
            if (a != null && checked == true) {
              await popAlarm(context, a);
            }
          }
        },
      );
    }
    return Container();
  }
}

class CheckButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CheckButton({
    this.onPressed,
  }) : super(key: TestKey.activityCheckButton);

  @override
  Widget build(BuildContext context) {
    final text = Translator.of(context).translate.check;
    return Tts.data(
      data: text,
      child: IconTheme(
        data: lightIconThemeData,
        child: TextButton.icon(
          onPressed: onPressed,
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(abiliaTextTheme.bodyText1),
            minimumSize: MaterialStateProperty.all(Size(0.0, 48.0.s)),
            padding: MaterialStateProperty.all(
              EdgeInsets.fromLTRB(10.0.s, 10.0.s, 20.0.s, 10.0.s),
            ),
            backgroundColor: buttonBackgroundGreen,
            foregroundColor: foregroundLight,
          ),
          icon: Icon(AbiliaIcons.handiCheck),
          label: Text(text),
        ),
      ),
    );
  }
}

class TopInfo extends StatelessWidget {
  const TopInfo({
    Key? key,
    required this.activityDay,
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
            padding: EdgeInsets.only(right: ActivityInfo.margin),
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
                  padding: EdgeInsets.only(bottom: 8.0.s),
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
