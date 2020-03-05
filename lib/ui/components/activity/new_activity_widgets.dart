import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

class NameAndPictureWidget extends StatelessWidget {
  final Activity activity;

  const NameAndPictureWidget(this.activity, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return SizedBox(
      height: 84,
      child: Row(
        children: <Widget>[
          BlocBuilder<AddActivityBloc, AddActivityState>(
              builder: (context, addActivityState) {
            final imageClick = () async {
              await showDialog(
                context: context,
                builder: (innerContext) => SelectPictureDialog(
                  outerContext: context,
                  onChanged: (imageId) {
                    BlocProvider.of<AddActivityBloc>(context)
                        .add(ImageSelected(imageId));
                  },
                ),
              );
            };
            return addActivityState.activity.hasImage
                ? InkWell(
                    onTap: imageClick,
                    child: FadeInCalendarImage(
                      imageFileId: addActivityState.activity.fileId,
                      imageFilePath: addActivityState.activity.icon,
                    ),
                  )
                : LinedBorder(
                    key: TestKey.addPicture,
                    padding: const EdgeInsets.all(26),
                    child: Icon(
                      AbiliaIcons.add_photo,
                      size: 32,
                      color: AbiliaColors.black[75],
                    ),
                    onTap: imageClick,
                  );
          }),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SubHeading(translator.name),
                TextFormField(
                  onChanged: (text) => BlocProvider.of<AddActivityBloc>(context)
                      .add(ChangeActivity(activity.copyWith(title: text))),
                  key: TestKey.newActivityNameInput,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final Activity activity;

  const CategoryWidget(this.activity, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.category),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: RadioField(
                key: TestKey.leftCategoryRadio,
                onChanged: (v) => BlocProvider.of<AddActivityBloc>(context)
                    .add(ChangeActivity(activity.copyWith(category: v))),
                leading: circle(),
                groupValue: activity.category,
                value: 0,
                label: Text(translator.left),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RadioField(
                key: TestKey.rightCategoryRadio,
                onChanged: (v) => BlocProvider.of<AddActivityBloc>(context)
                    .add(ChangeActivity(activity.copyWith(category: v))),
                leading: circle(),
                groupValue: activity.category,
                value: 1,
                label: Text(translator.right),
              ),
            ),
          ],
        )
      ],
    );
  }

  circle() => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AbiliaColors.transparantBlack[15],
          ),
          color: AbiliaColors.white,
        ),
      );
}

class AlarmWidget extends StatelessWidget {
  final Activity activity;

  const AlarmWidget(this.activity, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    final alarm = activity.alarm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.alarm),
        PickField(
          key: TestKey.selectAlarm,
          leading: Icon(alarm.iconData()),
          label: Text(alarm.text(translator)),
          onTap: () async {
            final result = await showDialog<Alarm>(
              context: context,
              builder: (context) => SelectAlarmTypeDialog(
                alarm: alarm.type,
              ),
            );
            if (result != null) {
              BlocProvider.of<AddActivityBloc>(context).add(ChangeActivity(
                  activity.copyWith(
                      alarm: activity.alarm.copyWith(type: result))));
            }
          },
        ),
        const SizedBox(height: 12),
        SwitchField(
          key: TestKey.alarmAtStartSwitch,
          leading: Icon(AbiliaIcons.handi_alarm),
          label: Text(translator.alarmOnlyAtStartTime),
          value: alarm.atEnd,
          onChanged: alarm.shouldAlarm
              ? (v) => BlocProvider.of<AddActivityBloc>(context).add(
                    ChangeActivity(
                        activity.copyWith(alarm: alarm.copyWith(onEndTime: v))),
                  )
              : null,
        ),
      ],
    );
  }
}

class CheckableAndDeleteAfterWidget extends StatelessWidget {
  final Activity activity;

  const CheckableAndDeleteAfterWidget(this.activity, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SwitchField(
          key: TestKey.checkableSwitch,
          leading: Icon(AbiliaIcons.handi_check),
          label: Text(translator.checkable),
          value: activity.checkable,
          onChanged: (v) => BlocProvider.of<AddActivityBloc>(context)
              .add(ChangeActivity(activity.copyWith(checkable: v))),
        ),
        const SizedBox(height: 12),
        SwitchField(
          key: TestKey.deleteAfterSwitch,
          leading: Icon(AbiliaIcons.delete_all_clear),
          label: Text(translator.deleteAfter),
          value: activity.removeAfter,
          onChanged: (v) => BlocProvider.of<AddActivityBloc>(context)
              .add(ChangeActivity(activity.copyWith(removeAfter: v))),
        ),
      ],
    );
  }
}

class AvailibleForWidget extends StatelessWidget {
  final Activity activity;

  const AvailibleForWidget(this.activity, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final bool secret = activity.secret;
    final translator = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.availableFor),
        PickField(
          key: TestKey.availibleFor,
          leading: Icon(secret
              ? AbiliaIcons.password_protection
              : AbiliaIcons.user_group),
          label:
              Text(secret ? translator.onlyMe : translator.meAndSupportPersons),
          onTap: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => SelectAvailableForDialog(
                secret: activity.secret,
              ),
            );
            if (result != null) {
              BlocProvider.of<AddActivityBloc>(context)
                  .add(ChangeActivity(activity.copyWith(secret: result)));
            }
          },
        ),
      ],
    );
  }
}
