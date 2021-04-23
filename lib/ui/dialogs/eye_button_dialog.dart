import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import 'all.dart';

class EyeButtonDialog extends StatefulWidget {
  final DayCalendarType currentCalendarType;
  final bool currentDotsInTimepillar;
  final TimepillarZoom currentZoom;
  final TimepillarIntervalType currentDayInterval;

  const EyeButtonDialog({
    Key key,
    @required this.currentCalendarType,
    @required this.currentDotsInTimepillar, 
    @required this.currentZoom,
    @required this.currentDayInterval,
  }) : super(key: key);

  @override
  _EyeButtonDialogState createState() => _EyeButtonDialogState(
        calendarType: currentCalendarType,
        dotsInTimePillar: currentDotsInTimepillar,
        timepillarZoom: currentZoom,
        dayInterval: currentDayInterval,
      );
}

class _EyeButtonDialogState extends State<EyeButtonDialog> {
  bool dotsInTimePillar;
  TimepillarZoom timepillarZoom;
  TimepillarIntervalType dayInterval;
  DayCalendarType calendarType;
  ScrollController _controller;

  _EyeButtonDialogState({
    @required this.calendarType,
    @required this.dotsInTimePillar,
    @required this.timepillarZoom,
    @required this.dayInterval,
  });

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return ViewDialog(
      heading: AppBarHeading(
        text: t.display,
        iconData: AbiliaIcons.show,
      ),
      body: AbiliaScrollBar(
        controller: _controller,
        child: ListView(
          children: [
            _addPadding(
              DuoSelector<DayCalendarType>(
                heading: t.viewMode,
                groupValue: calendarType,
                leftText: t.listView,
                rightText: t.timePillarView,
                leftValue: DayCalendarType.LIST,
                rightValue: DayCalendarType.TIMEPILLAR,
                leftIcon: AbiliaIcons.calendar_list,
                rightIcon: AbiliaIcons.timeline,
                onChanged: (type) {
                  setState(() {
                    calendarType = type;
                  });
                },
              ),
            ),
            Divider(
              endIndent: 16.s,
            ),
            CollapsableWidget(
              collapsed: calendarType == DayCalendarType.LIST,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ...[
                    TripleSelector<TimepillarIntervalType>(
                      heading: t.dayInterval,
                      groupValue: dayInterval,
                      leftText: t.interval,
                      midText: t.viewDay,
                      rightText: t.dayAndNight,
                      leftValue: TimepillarIntervalType.INTERVAL,
                      midValue: TimepillarIntervalType.DAY,
                      rightValue: TimepillarIntervalType.DAY_AND_NIGHT,
                      leftIcon: AbiliaIcons.day_interval,
                      midIcon: AbiliaIcons.sun,
                      rightIcon: AbiliaIcons.day_night,
                      onChanged: (newDayInterval) {
                        setState(() {
                          dayInterval = newDayInterval;
                        });
                      },
                    ),
                    Divider(
                      endIndent: 16.s,
                    ),
                    TripleSelector<TimepillarZoom>(
                      heading: t.zoom,
                      groupValue: timepillarZoom,
                      leftText: t.small,
                      midText: t.medium,
                      rightText: t.large,
                      leftValue: TimepillarZoom.SMALL,
                      midValue: TimepillarZoom.NORMAL,
                      rightValue: TimepillarZoom.LARGE,
                      leftIcon: AbiliaIcons.decrease_text,
                      midIcon: AbiliaIcons.decrease_text,
                      rightIcon: AbiliaIcons.enlarge_text,
                      onChanged: (newZoom) {
                        setState(() {
                          timepillarZoom = newZoom;
                        });
                      },
                    ),
                    Divider(
                      endIndent: 16.s,
                    ),
                    DuoSelector<bool>(
                      heading: t.activityDuration,
                      groupValue: dotsInTimePillar,
                      leftText: t.dots,
                      rightText: t.edge,
                      leftValue: true,
                      rightValue: false,
                      leftIcon: AbiliaIcons.options,
                      rightIcon: AbiliaIcons.flarp,
                      onChanged: (dots) {
                        setState(() {
                          dotsInTimePillar = dots;
                        });
                      },
                    ),
                  ].map(_addPadding),
                ],
              ),
            ),
          ],
        ),
      ),
      bodyPadding: EdgeInsets.zero,
      expanded: true,
      backNavigationWidget: CancelButton(),
      forwardNavigationWidget: OkButton(
        onPressed: () async {
          await Navigator.of(context).maybePop(EyeButtonSettings(
            calendarType: calendarType,
            dotsInTimepillar: dotsInTimePillar,
            timepillarZoom: timepillarZoom,
            intervalType: dayInterval,
          ));
        },
      ),
    );
  }

  Widget _addPadding(Widget widget) => widget is Divider
      ? widget
      : Padding(
          padding: EdgeInsets.fromLTRB(12.s, 24.s, 16.s, 8.s),
          child: widget,
        );
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
        Center(
          child: Tts(
            child: Text(
              heading,
              style: abiliaTextTheme.bodyText2.copyWith(
                color: AbiliaColors.black75,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.0.s),
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
                width: 2.s,
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

class TripleSelector<T> extends StatelessWidget {
  final String heading;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final String leftText;
  final String midText;
  final String rightText;
  final T leftValue;
  final T midValue;
  final T rightValue;
  final IconData leftIcon;
  final IconData midIcon;
  final IconData rightIcon;

  const TripleSelector({
    Key key,
    @required this.heading,
    @required this.groupValue,
    @required this.onChanged,
    @required this.leftValue,
    @required this.midValue,
    @required this.rightValue,
    @required this.leftText,
    @required this.midText,
    @required this.rightText,
    @required this.leftIcon,
    @required this.midIcon,
    @required this.rightIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Tts(
            child: Text(
              heading,
              style: abiliaTextTheme.bodyText2.copyWith(
                color: AbiliaColors.black75,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.0.s),
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
                width: 2.s,
              ),
              Expanded(
                child: _SelectButton<T>(
                  text: midText,
                  onPressed: () => onChanged(midValue),
                  groupValue: groupValue,
                  value: midValue,
                  borderRadius: BorderRadius.zero,
                  icon: midIcon,
                ),
              ),
              SizedBox(
                width: 2.s,
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
    return Tts(
      data: text,
      child: TextButton(
        onPressed: onPressed,
        style: tabButtonStyle(
          borderRadius: borderRadius,
          isSelected: value == groupValue,
        ).copyWith(
          textStyle: MaterialStateProperty.all(abiliaTextTheme.subtitle2),
          padding: MaterialStateProperty.all(EdgeInsets.only(bottom: 8.0.s)),
        ),
        child: Column(
          children: [
            Text(text),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}
