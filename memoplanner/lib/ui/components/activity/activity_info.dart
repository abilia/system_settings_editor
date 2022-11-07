import 'package:flutter/services.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ActivityInfoWithDots extends StatelessWidget {
  final ActivityDay activityDay;
  final Widget? previewImage;
  final NewAlarm? alarm;

  const ActivityInfoWithDots(
    this.activityDay, {
    Key? key,
    this.alarm,
    this.previewImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayQuarterHour = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.activityView.displayQuarterHour);
    return Row(
      children: [
        if (displayQuarterHour) ActivityInfoSideDots(activityDay),
        Expanded(
          child: Padding(
            padding: layout.activityPage.horizontalInfoPadding.copyWith(
              left: displayQuarterHour
                  ? 0
                  : layout.activityPage.horizontalInfoPadding.left,
            ),
            child: ActivityInfo(
              activityDay,
              previewImage: previewImage,
              alarm: alarm,
              showCheckButton: true,
            ),
          ),
        ),
      ],
    );
  }
}

class ActivityInfo extends StatelessWidget with ActivityMixin {
  final ActivityDay activityDay;
  final Widget? previewImage;
  final ActivityAlarm? alarm;
  final bool showCheckButton;

  const ActivityInfo(
    this.activityDay, {
    this.showCheckButton = false,
    Key? key,
    this.previewImage,
    this.alarm,
  }) : super(key: key);

  @visibleForTesting
  factory ActivityInfo.from({
    required Activity activity,
    required DateTime day,
    Key? key,
  }) =>
      ActivityInfo(
        ActivityDay(activity, day),
        showCheckButton: true,
        key: key,
      );

  static const animationDuration = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final showCheck = showCheckButton &&
        activityDay.activity.checkable &&
        !activityDay.isSignedOff;
    final verticalPadding = showCheck
        ? layout.activityPage.verticalInfoPaddingCheckable
        : layout.activityPage.verticalInfoPaddingNonCheckable;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: verticalPadding.top),
        ActivityTopInfo(
          activityDay,
          alarm: alarm,
        ),
        Expanded(
          child: Container(
            decoration: boxDecoration,
            child: ActivityContainer(
              activityDay: activityDay,
              previewImage: previewImage,
              alarm: alarm,
            ),
          ),
        ),
        SizedBox(height: verticalPadding.bottom),
        if (showCheck)
          Padding(
            padding: layout.activityPage.checkButtonPadding,
            child: CheckButton(
              onPressed: () => checkConfirmation(context, activityDay),
            ),
          ),
      ],
    );
  }
}

mixin ActivityMixin {
  static final _log = Logger((ActivityMixin).toString());

  Future<bool?> checkConfirmation(
    BuildContext context,
    ActivityDay activityDay, {
    String? message,
  }) async {
    final activitiesBloc = context.read<ActivitiesBloc>();
    final check = await showViewDialog<bool>(
      context: context,
      builder: (_) => CheckActivityConfirmDialog(
        activityDay: activityDay,
        message: message,
      ),
    );
    if (check == true) {
      activitiesBloc.add(
        UpdateActivity(
          activityDay.activity.signOff(activityDay.day),
        ),
      );
    }
    return check;
  }

  Future checkConfirmationAndRemoveAlarm(
    BuildContext context,
    ActivityDay activityDay, {
    ActivityAlarm? alarm,
    String? message,
  }) async {
    final activityRepository =
        alarm != null && context.read<LicenseCubit>().validLicense
            ? context.read<ActivityRepository>()
            : null;

    final navigator = Navigator.of(context);
    final checked = await checkConfirmation(
      context,
      activityDay,
      message: message,
    );
    if (checked == true && alarm != null) {
      await cancelNotifications(uncheckedReminders(alarm.activityDay));
      await popAlarm(
        activityRepository: activityRepository,
        navigator: navigator,
        alarm: alarm,
      );
    }
  }

  Future popAlarm({
    required NavigatorState navigator,
    required NotificationAlarm alarm,
    ActivityRepository? activityRepository,
  }) async {
    _log.fine('pop Alarm: $alarm');
    if (!await navigator.maybePop()) {
      _log.info('Could not pop (root?) will -> SystemNavigator.pop');
      await activityRepository?.synchronize().catchError((_) => false);
      await SystemNavigator.pop();
    }
  }
}

class ActivityContainer extends StatelessWidget {
  const ActivityContainer({
    required this.activityDay,
    this.alarm,
    this.previewImage,
    Key? key,
  }) : super(key: key);

  final ActivityDay activityDay;
  final Widget? previewImage;
  final ActivityAlarm? alarm;

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final hasAttachment = activity.hasAttachment;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: borderRadius,
      ),
      constraints: const BoxConstraints.expand(),
      child: Column(
        children: [
          TitleAndOrImage(
            activityDay: activityDay,
            previewImage: previewImage,
          ),
          if (hasAttachment)
            Expanded(
              key: TestKey.attachment,
              child: Column(
                children: [
                  if (activityDay.activity.infoItem.runtimeType !=
                      UrlInfoItem) ...[
                    SizedBox(
                      height: layout.activityPage.dividerTopPadding,
                    ),
                    Divider(
                      height: layout.activityPage.dividerHeight,
                      endIndent: 0,
                      indent: layout.activityPage.dividerIndentation,
                    ),
                  ],
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
  final ActivityAlarm? alarm;

  const Attachment({
    required this.activityDay,
    this.alarm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activity = alarm?.activity ?? activityDay.activity;
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
          context.read<ActivityCubit>().onActivityUpdated(updatedActivity);

          if (signedOff.allSignedOff(activityDay.day) &&
              updatedActivity.checkable &&
              !activityDay.isSignedOff) {
            await checkConfirmationAndRemoveAlarm(
              context,
              ActivityDay(updatedActivity, activityDay.day),
              alarm: alarm,
              message: Translator.of(context).translate.checklistDoneInfo,
            );
          }
        },
      );
    } else if (item is UrlInfoItem) {
      return Padding(
        padding: layout.activityPage.youtubePlayerPadding,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: YoutubePlayer(
            url: item.url,
          ),
        ),
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
            minimumSize: MaterialStateProperty.all(
              Size(0, layout.activityPage.checkButtonHeight),
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
    required this.activityDay,
    this.previewImage,
    Key? key,
  }) : super(key: key);

  final ActivityDay activityDay;
  final Widget? previewImage;

  Widget get image =>
      previewImage ??
      (activityDay.activity.hasAttachment
          ? CheckedImageWithImagePopup(activityDay: activityDay)
          : CheckedImageWithImagePopup(
              activityDay: activityDay,
              checkPadding: layout.activityPage.checkPadding,
            ));

  Widget get title => Tts(
        child: Text(
          activityDay.activity.title,
          style: layout.activityPage.headline4_2(),
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final activity = activityDay.activity;
    final hasImage = activity.hasImage || previewImage != null;
    final hasTitle = activity.hasTitle;
    final hasAttachment = activity.hasAttachment;

    if (hasAttachment) {
      return SizedBox(
        height: layout.activityPage.topInfoHeight,
        child: Padding(
          padding: layout.activityPage.topInfoPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasImage)
                image
              else if (activityDay.isSignedOff)
                const CheckMark(),
              if (hasImage && hasTitle)
                SizedBox(
                  width: layout.activityPage.titleImageHorizontalSpacing,
                ),
              if (hasTitle) Expanded(child: title),
            ],
          ),
        ),
      );
    } else {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasTitle)
              SizedBox(
                height: layout.activityPage.topInfoHeight,
                child: Center(child: title),
              ),
            if (hasImage || activityDay.isSignedOff)
              Expanded(
                child: Padding(
                  padding: layout.activityPage.imagePadding,
                  child: Center(child: image),
                ),
              ),
          ],
        ),
      );
    }
  }
}
