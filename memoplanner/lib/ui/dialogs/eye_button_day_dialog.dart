import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class EyeButtonDayDialog extends StatefulWidget {
  final DayCalendarType currentCalendarType;
  final bool currentDotsInTimepillar;
  final TimepillarZoom currentZoom;
  final TimepillarIntervalType currentDayInterval;

  const EyeButtonDayDialog({
    required this.currentCalendarType,
    required this.currentDotsInTimepillar,
    required this.currentZoom,
    required this.currentDayInterval,
    super.key,
  });

  @override
  State createState() => _EyeButtonDayDialogState();
}

class _EyeButtonDayDialogState extends State<EyeButtonDayDialog> {
  late bool dotsInTimePillar;
  late TimepillarZoom timepillarZoom;
  late TimepillarIntervalType dayInterval;
  late DayCalendarType calendarType;
  final _controller = ScrollController();

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
    final translate = Lt.of(context);
    final displaySettings =
        context.select((DayCalendarViewCubit cubit) => cubit.state.display);
    final dividerPad = EdgeInsets.only(
        top: layout.formPadding.horizontalItemDistance,
        bottom: layout.formPadding.groupBottomDistance);
    return ViewDialog(
      heading: AppBarHeading(
        text: translate.display,
        iconData: AbiliaIcons.show,
      ),
      body: ScrollArrows.vertical(
        controller: _controller,
        child: ListView(
          controller: _controller,
          children: [
            SizedBox(
              height: layout.templates.m1.top,
            ),
            if (displaySettings.calendarType) ...[
              Selector<DayCalendarType>(
                heading: translate.viewMode,
                groupValue: calendarType,
                items: [
                  SelectorItem(
                    translate.listView,
                    AbiliaIcons.calendarList,
                    DayCalendarType.list,
                  ),
                  SelectorItem(
                    translate.oneTimePillarView,
                    AbiliaIcons.timeline,
                    DayCalendarType.oneTimepillar,
                  ),
                  SelectorItem(
                    translate.twoTimePillarsView,
                    AbiliaIcons.twoTimelines,
                    DayCalendarType.twoTimepillars,
                  ),
                ],
                onChanged: (type) => setState(() => calendarType = type),
              ).pad(layout.templates.m1.onlyHorizontal),
              const Divider().pad(dividerPad)
            ],
            CollapsableWidget(
              collapsed: calendarType != DayCalendarType.oneTimepillar,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ...[
                    if (displaySettings.intervalType) ...[
                      Selector<TimepillarIntervalType>(
                        heading: translate.dayInterval,
                        groupValue: dayInterval,
                        items: [
                          SelectorItem(
                            translate.interval,
                            AbiliaIcons.dayInterval,
                            TimepillarIntervalType.interval,
                          ),
                          SelectorItem(
                            translate.viewDay,
                            AbiliaIcons.sun,
                            TimepillarIntervalType.day,
                          ),
                          SelectorItem(
                            translate.dayAndNight,
                            AbiliaIcons.dayNight,
                            TimepillarIntervalType.dayAndNight,
                          ),
                        ],
                        onChanged: (newDayInterval) =>
                            setState(() => dayInterval = newDayInterval),
                      ).pad(layout.templates.m1.onlyHorizontal),
                      const Divider().pad(dividerPad)
                    ],
                    if (displaySettings.timepillarZoom) ...[
                      Selector<TimepillarZoom>(
                        heading: translate.timelineZoom,
                        groupValue: timepillarZoom,
                        items: [
                          SelectorItem(
                            translate.small,
                            AbiliaIcons.decreaseText,
                            TimepillarZoom.small,
                          ),
                          SelectorItem(
                            translate.medium,
                            AbiliaIcons.mediumText,
                            TimepillarZoom.normal,
                          ),
                          SelectorItem(
                            translate.large,
                            AbiliaIcons.enlargeText,
                            TimepillarZoom.large,
                          ),
                        ],
                        onChanged: (newZoom) {
                          setState(() {
                            timepillarZoom = newZoom;
                          });
                        },
                      ).pad(layout.templates.m1.onlyHorizontal),
                      const Divider().pad(dividerPad)
                    ],
                  ],
                ],
              ),
            ),
            CollapsableWidget(
              collapsed: calendarType == DayCalendarType.list,
              child: displaySettings.duration
                  ? Selector<bool>(
                      heading: translate.activityDuration,
                      groupValue: dotsInTimePillar,
                      items: [
                        SelectorItem(
                          translate.dots,
                          AbiliaIcons.options,
                          true,
                        ),
                        SelectorItem(
                          translate.edge,
                          AbiliaIcons.flarp,
                          false,
                        ),
                      ],
                      onChanged: (dots) =>
                          setState(() => dotsInTimePillar = dots),
                    )
                  : Container(),
            ).pad(layout.templates.m1.onlyHorizontal),
            SizedBox(
              height: layout.templates.m1.bottom,
            ),
          ],
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
