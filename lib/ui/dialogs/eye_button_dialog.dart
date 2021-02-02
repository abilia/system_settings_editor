import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import 'all.dart';

class EyeButtonDialog extends StatefulWidget {
  final CalendarType currentCalendarType;
  final bool currentDotsInTimepillar;
  const EyeButtonDialog({
    Key key,
    @required this.currentCalendarType,
    @required this.currentDotsInTimepillar,
  }) : super(key: key);

  @override
  _EyeButtonDialogState createState() => _EyeButtonDialogState(
        calendarType: currentCalendarType,
        dotsInTimePillar: currentDotsInTimepillar,
      );
}

class _EyeButtonDialogState extends State<EyeButtonDialog> {
  bool dotsInTimePillar;
  CalendarType calendarType;

  _EyeButtonDialogState({
    @required this.calendarType,
    @required this.dotsInTimePillar,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SmallDialog(
      heading: AppBarHeading(
        text: t.display,
        iconData: AbiliaIcons.show,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 16, 8),
            child: DuoSelector<CalendarType>(
              heading: t.viewMode,
              groupValue: calendarType,
              leftText: t.listView,
              leftValue: CalendarType.LIST,
              onChanged: (type) {
                setState(() {
                  calendarType = type;
                });
              },
              rightText: t.timePillarView,
              rightValue: CalendarType.TIMEPILLAR,
              leftIcon: AbiliaIcons.calendar_list,
              rightIcon: AbiliaIcons.timeline,
            ),
          ),
          Divider(
            endIndent: 16,
          ),
          CollapsableWidget(
            collapsed: calendarType == CalendarType.LIST,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
              child: DuoSelector<bool>(
                heading: t.activityDuration,
                groupValue: dotsInTimePillar,
                leftText: t.dots,
                leftValue: true,
                onChanged: (dots) {
                  setState(() {
                    dotsInTimePillar = dots;
                  });
                },
                rightText: t.edge,
                rightValue: false,
                leftIcon: AbiliaIcons.options,
                rightIcon: AbiliaIcons.flarp,
              ),
            ),
          ),
        ],
      ),
      bodyPadding: EdgeInsets.zero,
      expanded: true,
      backNavigationWidget: CancelButton(),
      forwardNavigationWidget: OkButton(
        onPressed: () async {
          await Navigator.of(context).maybePop(EyeButtonSettings(
            calendarType: calendarType,
            dotsInTimepillar: dotsInTimePillar,
          ));
        },
      ),
    );
  }
}

class DuoSelector<T> extends StatelessWidget {
  final String heading;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final String leftText;
  final String rightText;
  final T leftValue;
  final T rightValue;
  final IconData leftIcon;
  final IconData rightIcon;

  const DuoSelector({
    Key key,
    @required this.heading,
    @required this.groupValue,
    @required this.onChanged,
    @required this.leftValue,
    @required this.rightValue,
    @required this.leftText,
    @required this.rightText,
    @required this.leftIcon,
    @required this.rightIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Tts(
          child: Text(
            heading,
            style: abiliaTextTheme.bodyText2.copyWith(
              color: AbiliaColors.black75,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            child: Row(children: [
              Expanded(
                child: _SelectButton<T>(
                  text: leftText,
                  onPressed: () => onChanged(leftValue),
                  groupValue: groupValue,
                  value: leftValue,
                  borderRadius: borderRadiusLeft,
                  icon: leftIcon,
                ),
              ),
              SizedBox(
                width: 2,
              ),
              Expanded(
                child: _SelectButton<T>(
                  text: rightText,
                  onPressed: () => onChanged(rightValue),
                  groupValue: groupValue,
                  value: rightValue,
                  borderRadius: borderRadiusRight,
                  icon: rightIcon,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SelectButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String text;
  final IconData icon;
  final BorderRadius borderRadius;
  final VoidCallback onPressed;

  const _SelectButton({
    @required this.onPressed,
    @required this.value,
    @required this.groupValue,
    @required this.text,
    @required this.borderRadius,
    @required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final textColor = isSelected ? AbiliaColors.white : AbiliaColors.black;
    return Tts(
      data: text,
      child: FlatButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            children: [
              Text(
                text,
                style: abiliaTextTheme.subtitle2.copyWith(
                  color: textColor,
                ),
              ),
              IconTheme(
                  data: Theme.of(context).iconTheme.copyWith(
                        color: textColor,
                      ),
                  child: Icon(icon)),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: isSelected
              ? BorderSide.none
              : BorderSide(color: AbiliaColors.transparentBlack30),
        ),
        color:
            isSelected ? AbiliaColors.green : AbiliaColors.transparentBlack20,
      ),
    );
  }
}
