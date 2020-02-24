import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

class NameAndPictureWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;

    return SizedBox(
      height: 84,
      child: Row(
        children: <Widget>[
          LinedBorder(
            onTap: () {},
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
              onChanged: (v) {},
              leading: circle(),
              groupValue: true,
              value: true,
              label: Text(translator.left),
            ),
            const SizedBox(width: 8),
            RadioField(
              onChanged: (v) {},
              leading: circle(),
              groupValue: false,
              value: true,
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
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(translator.alarm),
        PickField(
          onTap: () {},
          leading: Icon(AbiliaIcons.handi_alarm_vibration),
          label: Text(translator.alarmAndVibration),
        ),
        const SizedBox(height: 12),
        SwitchField(
          leading: Icon(AbiliaIcons.handi_alarm),
          label: Text(translator.alarmOnlyAtStartTime),
        ),
      ],
    );
  }
}

class CheckableAndDeleteAfterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SwitchField(
          leading: Icon(AbiliaIcons.handi_check),
          label: Text(translator.checkable),
        ),
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
          onTap: () {},
          leading: Icon(AbiliaIcons.user_group),
          label: Text(translator.meAndSupportPersons),
        ),
      ],
    );
  }
}
