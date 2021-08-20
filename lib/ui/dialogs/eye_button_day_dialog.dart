import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import 'all.dart';

class EyeButtonDayDialog extends StatefulWidget {
  final DayCalendarType currentCalendarType;
  final bool currentDotsInTimepillar;
  final TimepillarZoom currentZoom;
  final TimepillarIntervalType currentDayInterval;

  const EyeButtonDayDialog({
    Key? key,
    required this.currentCalendarType,
    required this.currentDotsInTimepillar,
    required this.currentZoom,
    required this.currentDayInterval,
  }) : super(key: key);

  @override
  _EyeButtonDayDialogState createState() => _EyeButtonDayDialogState(
        calendarType: currentCalendarType,
        dotsInTimePillar: currentDotsInTimepillar,
        timepillarZoom: currentZoom,
        dayInterval: currentDayInterval,
      );
}

class _EyeButtonDayDialogState extends State<EyeButtonDayDialog> {
  bool dotsInTimePillar;
  TimepillarZoom timepillarZoom;
  TimepillarIntervalType dayInterval;
  DayCalendarType calendarType;

  _EyeButtonDayDialogState({
    required this.calendarType,
    required this.dotsInTimePillar,
    required this.timepillarZoom,
    required this.dayInterval,
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
        child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
          builder: (context, state) => ListView(
            children: [
              if (state.settingViewOptionsTimeView) ...[
                _addPadding(
                  Selector<DayCalendarType>(
                    heading: t.viewMode,
                    groupValue: calendarType,
                    items: [
                      SelectorItem(
                        t.listView,
                        AbiliaIcons.calendar_list,
                        DayCalendarType.list,
                      ),
                      SelectorItem(
                        t.timePillarView,
                        AbiliaIcons.timeline,
                        DayCalendarType.timepillar,
                      ),
                    ],
                    onChanged: (type) => setState(() => calendarType = type),
                  ),
                ),
                Divider(endIndent: 16.s)
              ],
              CollapsableWidget(
                collapsed: calendarType == DayCalendarType.list,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ...[
                      if (state.settingViewOptionsTimeInterval) ...[
                        Selector<TimepillarIntervalType>(
                          heading: t.dayInterval,
                          groupValue: dayInterval,
                          items: [
                            SelectorItem(
                              t.interval,
                              AbiliaIcons.day_interval,
                              TimepillarIntervalType.INTERVAL,
                            ),
                            SelectorItem(
                              t.viewDay,
                              AbiliaIcons.sun,
                              TimepillarIntervalType.DAY,
                            ),
                            SelectorItem(
                              t.dayAndNight,
                              AbiliaIcons.day_night,
                              TimepillarIntervalType.DAY_AND_NIGHT,
                            ),
                          ],
                          onChanged: (newDayInterval) =>
                              setState(() => dayInterval = newDayInterval),
                        ),
                        Divider(endIndent: 16.s)
                      ],
                      if (state.settingViewOptionsZoom) ...[
                        Selector<TimepillarZoom>(
                          heading: t.zoom,
                          groupValue: timepillarZoom,
                          items: [
                            SelectorItem(
                              t.small,
                              AbiliaIcons.decrease_text,
                              TimepillarZoom.SMALL,
                            ),
                            SelectorItem(
                              t.medium,
                              AbiliaIcons.medium_text,
                              TimepillarZoom.NORMAL,
                            ),
                            SelectorItem(
                              t.large,
                              AbiliaIcons.enlarge_text,
                              TimepillarZoom.LARGE,
                            ),
                          ],
                          onChanged: (newZoom) {
                            setState(() {
                              timepillarZoom = newZoom;
                            });
                          },
                        ),
                        Divider(endIndent: 16.s)
                      ],
                      if (state.settingViewOptionsDurationDots)
                        Selector<bool>(
                          heading: t.activityDuration,
                          groupValue: dotsInTimePillar,
                          items: [
                            SelectorItem(
                              t.dots,
                              AbiliaIcons.options,
                              true,
                            ),
                            SelectorItem(
                              t.edge,
                              AbiliaIcons.flarp,
                              false,
                            ),
                          ],
                          onChanged: (dots) =>
                              setState(() => dotsInTimePillar = dots),
                        ),
                    ].map(_addPadding),
                  ],
                ),
              ),
            ],
          ),
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
