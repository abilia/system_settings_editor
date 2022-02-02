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
  Widget build(BuildContext context) =>
      BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState, bool>(
        selector: (state) => state.displayQuarterHour,
        builder: (context, displayQuarter) => Row(
          children: [
            if (displayQuarter) ActivityInfoSideDots(activityDay),
            Expanded(
              child: Padding(
                padding: layout.activityPage.horizontalInfoPadding.copyWith(
                  left: displayQuarter
                      ? 0
                      : layout.activityPage.horizontalInfoPadding.left,
                ),
                child: ActivityInfo(
                  activityDay,
                  previewImage: previewImage,
                ),
              ),
            ),
          ],
        ),
      );
}

class ActivityInfo extends StatefulWidget {
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
      final showCheckButton =
          widget.alarm == null && activity.checkable && !occasion.isSignedOff;
      final verticalPadding = showCheckButton
          ? layout.activityPage.verticalInfoPaddingCheckable
          : layout.activityPage.verticalInfoPaddingNonCheckable;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: verticalPadding.top),
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
          SizedBox(height: verticalPadding.bottom),
          if (showCheckButton)
            Padding(
              padding: layout.activityPage.checkButtonPadding,
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
    ActivityDay activityDay, {
    String? message,
  }) async {
    final check = await showViewDialog<bool>(
      context: context,
      builder: (_) => CheckActivityConfirmDialog(
        activityDay: activityDay,
        message: message,
      ),
    );
    if (check == true) {
      context.read<ActivitiesBloc>().add(
            UpdateActivity(
              activityDay.activity.signOff(activityDay.day),
            ),
          );
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
    final hasAttachment = activity.hasAttachment;
    return Container(
      decoration: BoxDecoration(
        color: activityDay.isSignedOff
            ? inactiveGrey
            : Theme.of(context).cardColor,
        borderRadius: borderRadius,
      ),
      constraints: const BoxConstraints.expand(),
      child: Column(
        children: [
          if (true)
            TitleAndOrImage(
              activityDay: activityDay,
              previewImage: previewImage,
            ),
          if (hasAttachment)
            Expanded(
              key: TestKey.attachment,
              child: Column(
                children: [
                  Divider(
                    height: layout.activityPage.dividerHeight,
                    endIndent: 0,
                    indent: layout.activityPage.dividerIndentation,
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
        ],
      ),
    );
  }
}

class Attachment extends StatelessWidget with ActivityMixin {
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
        padding: layout.activityPage.checklistPadding,
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
              ActivityDay(updatedActivity, activityDay.day),
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
            textStyle: MaterialStateProperty.all(
                abiliaTextTheme.bodyText1!.copyWith(height: 1)),
            minimumSize: MaterialStateProperty.all(
              Size(0.0, layout.activityPage.checkButtonHeight),
            ),
            padding: MaterialStateProperty.all(
              layout.activityPage.checkButtonContentPadding,
            ),
            backgroundColor: buttonBackgroundGreen,
            foregroundColor: foregroundLight,
            shape: MaterialStateProperty.all(
              ligthShapeBorder.copyWith(
                side: ligthShapeBorder.side
                    .copyWith(color: AbiliaColors.green140),
              ),
            ),
          ),
          icon: const Icon(AbiliaIcons.handiCheck),
          label: Text(text),
        ),
      ),
    );
  }
}

class TitleAndOrImage extends StatelessWidget {
  const TitleAndOrImage({
    Key? key,
    required this.activityDay,
    this.previewImage,
  }) : super(key: key);

  final ActivityDay activityDay;
  final Widget? previewImage;

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final hasImage = activity.hasImage;
    final hasTitle = activity.hasTitle;
    final hasAttachment = activity.hasAttachment;

    final checkableImage = CheckedImageWithImagePopup(activityDay: activityDay);

    final title = hasTitle
        ? Tts(
            child: Text(
              activity.title,
              style: layout.activityPage.titleStyle(),
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
            ),
          )
        : const SizedBox.shrink();

    final image = previewImage ?? checkableImage;

    if (hasAttachment) {
      return SizedBox(
        height: layout.activityPage.topInfoHeight,
        child: Padding(
          padding: layout.activityPage.topInfoPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasImage) image,
              if (hasImage && hasTitle)
                SizedBox(
                  width: layout.activityPage.titleImageHorizontalSpacing,
                ),
              if (hasTitle)
                Expanded(
                  child: title,
                ),
            ],
          ),
        ),
      );
    } else {
      return Expanded(
        child: Column(
          children: [
            if (hasTitle)
              SizedBox(
                height: layout.activityPage.topInfoHeight,
                child: Center(
                  child: title,
                ),
              ),
            if (hasImage || activityDay.isSignedOff)
              Expanded(
                child: Padding(
                  padding: layout.activityPage.imagePadding,
                  child: Center(
                    child: image,
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }
}
