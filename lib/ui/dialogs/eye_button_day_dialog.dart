import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

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
  _EyeButtonDayDialogState createState() => _EyeButtonDayDialogState();
}

class _EyeButtonDayDialogState extends State<EyeButtonDayDialog> {
  late bool dotsInTimePillar;
  late TimepillarZoom timepillarZoom;
  late TimepillarIntervalType dayInterval;
  late DayCalendarType calendarType;

  @override
  void initState() {
    super.initState();
    dotsInTimePillar = widget.currentDotsInTimepillar;
    timepillarZoom = widget.currentZoom;
    dayInterval = widget.currentDayInterval;
    calendarType = widget.currentCalendarType;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final dividerPad = EdgeInsets.only(
        top: layout.formPadding.horizontalItemDistance,
        bottom: layout.formPadding.groupBottomDistance);
    return ViewDialog(
      heading: AppBarHeading(
        text: t.display,
        iconData: AbiliaIcons.show,
      ),
      body: AbiliaScrollBar(
        child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
          builder: (context, state) => ListView(
            children: [
              SizedBox(
                height: layout.templates.m1.top,
              ),
              if (state.settingViewOptionsTimeView) ...[
                Selector<DayCalendarType>(
                  heading: t.viewMode,
                  groupValue: calendarType,
                  items: [
                    SelectorItem(
                      t.listView,
                      AbiliaIcons.calendarList,
                      DayCalendarType.list,
                    ),
                    SelectorItem(
                      t.oneTimePillarView,
                      AbiliaIcons.timeline,
                      DayCalendarType.oneTimepillar,
                    ),
                    SelectorItem(
                      t.twoTimePillarsView,
                      AbiliaIcons.twoTimelines,
                      DayCalendarType.twoTimepillars,
                    ),
                  ],
                  onChanged: (type) => setState(() => calendarType = type),
                ).pad(m1Horizontal),
                const Divider().pad(dividerPad)
              ],
              CollapsableWidget(
                collapsed: calendarType != DayCalendarType.oneTimepillar,
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
                              AbiliaIcons.dayInterval,
                              TimepillarIntervalType.interval,
                            ),
                            SelectorItem(
                              t.viewDay,
                              AbiliaIcons.sun,
                              TimepillarIntervalType.day,
                            ),
                            SelectorItem(
                              t.dayAndNight,
                              AbiliaIcons.dayNight,
                              TimepillarIntervalType.dayAndNight,
                            ),
                          ],
                          onChanged: (newDayInterval) =>
                              setState(() => dayInterval = newDayInterval),
                        ).pad(m1Horizontal),
                        const Divider().pad(dividerPad)
                      ],
                      if (state.settingViewOptionsZoom) ...[
                        Selector<TimepillarZoom>(
                          heading: t.zoom,
                          groupValue: timepillarZoom,
                          items: [
                            SelectorItem(
                              t.small,
                              AbiliaIcons.decreaseText,
                              TimepillarZoom.small,
                            ),
                            SelectorItem(
                              t.medium,
                              AbiliaIcons.mediumText,
                              TimepillarZoom.normal,
                            ),
                            SelectorItem(
                              t.large,
                              AbiliaIcons.enlargeText,
                              TimepillarZoom.large,
                            ),
                          ],
                          onChanged: (newZoom) {
                            setState(() {
                              timepillarZoom = newZoom;
                            });
                          },
                        ).pad(m1Horizontal),
                        const Divider().pad(dividerPad)
                      ],
                    ],
                  ],
                ),
              ),
              if (state.settingViewOptionsDurationDots)
                CollapsableWidget(
                  collapsed: calendarType == DayCalendarType.list,
                  child: Selector<bool>(
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
                ).pad(m1Horizontal),
            ],
          ),
        ),
      ),
      bodyPadding: EdgeInsets.zero,
      expanded: true,
      backNavigationWidget: const CancelButton(),
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
}
