import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import 'all.dart';

class EyeButtonDialog extends StatelessWidget {
  const EyeButtonDialog({
    Key key,
  }) : super(key: key);

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
              groupValue: CalendarType.LIST,
              leftText: t.listView,
              leftValue: CalendarType.LIST,
              onChanged: (t) {},
              rightText: t.timePillarView,
              rightValue: CalendarType.TIMEPILLAR,
              leftIcon: AbiliaIcons.calendar,
              rightIcon: AbiliaIcons.timeline,
            ),
          ),
          Separator(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
            child: DuoSelector<bool>(
              heading: t.activityDuration,
              groupValue: true,
              leftText: t.dots,
              leftValue: true,
              onChanged: (t) {},
              rightText: t.edge,
              rightValue: false,
              leftIcon: AbiliaIcons.options,
              rightIcon: AbiliaIcons.flarp,
            ),
          ),
        ],
      ),
      bodyPadding: EdgeInsets.all(0),
      expanded: true,
      backNavigationWidget: GreyButton(
        text: Translator.of(context).translate.cancel,
        icon: AbiliaIcons.close_program,
        onPressed: Navigator.of(context).maybePop,
      ),
      forwardNavigationWidget: GreenButton(
        icon: AbiliaIcons.ok,
        text: Translator.of(context).translate.ok,
        onPressed: () {},
      ),
    );
  }
}

class Separator extends StatelessWidget {
  const Separator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AbiliaColors.white120),
          ),
        ),
      ),
    );
  }
}

class TwoValueSelector extends StatelessWidget {
  final String heading;
  const TwoValueSelector({Key key, this.heading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(heading),
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
        Tts(child: Text(heading, style: abiliaTextTheme.bodyText2)),
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
