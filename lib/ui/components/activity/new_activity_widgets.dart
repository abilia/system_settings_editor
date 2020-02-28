import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
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
          LinedBorder(
            padding: const EdgeInsets.all(26),
            child: Icon(
              AbiliaIcons.add_photo,
              size: 32,
              color: AbiliaColors.black[75],
            ),
          ),
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
            RadioField(
              key: TestKey.leftCategoryRadio,
              onChanged: (v) => BlocProvider.of<AddActivityBloc>(context)
                  .add(ChangeActivity(activity.copyWith(category: v))),
              leading: circle(),
              groupValue: activity.category,
              value: 0,
              label: Text(translator.left),
            ),
            const SizedBox(width: 8),
            RadioField(
              key: TestKey.rightCategoryRadio,
              onChanged: (v) => BlocProvider.of<AddActivityBloc>(context)
                  .add(ChangeActivity(activity.copyWith(category: v))),
              leading: circle(),
              groupValue: activity.category,
              value: 1,
              label: Text(translator.right),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.alarm),
        PickField(
          leading: Icon(AbiliaIcons.handi_alarm_vibration),
          label: Text(translator.alarmAndVibration),
        ),
        const SizedBox(height: 12),
        SwitchField(
          key: TestKey.alarmAtStartSwitch,
          leading: Icon(AbiliaIcons.handi_alarm),
          label: Text(translator.alarmOnlyAtStartTime),
          value: activity.alarm.atEnd,
          onChanged: (v) => BlocProvider.of<AddActivityBloc>(context).add(
              ChangeActivity(activity.copyWith(
                  alarm: activity.alarm.copyWith(onEndTime: v)))),
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
                .add(ChangeActivity(activity.copyWith(checkable: v)))),
        const SizedBox(height: 12),
        SwitchField(
          leading: Icon(AbiliaIcons.delete_all_clear),
          label: Text(translator.deleteAfter),
        ),
      ],
    );
  }
}

class AvailibleForWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.availableFor),
        PickField(
          leading: Icon(AbiliaIcons.user_group),
          label: Text(translator.meAndSupportPersons),
        ),
      ],
    );
  }
}
