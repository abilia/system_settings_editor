import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class EyeButtonSettingsTab extends StatelessWidget {
  const EyeButtonSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Lt.of(context);
    final scrollController = ScrollController();
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettings>(
        builder: (context, dayCalendarSettings) {
      final displaySettings = dayCalendarSettings.viewOptions.display;
      return ScrollArrows.vertical(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          padding: layout.templates.m1.onlyVertical,
          children: [
            Tts(child: Text(t.viewSettings)).pad(
              layout.templates.m1.onlyHorizontal,
            ),
            CollapsableWidget(
              collapsed: !displaySettings.calendarType,
              child: _buildSelector(
                [
                  SelectorItem(t.listView, AbiliaIcons.calendarList),
                  SelectorItem(t.oneTimePillarView, AbiliaIcons.timeline),
                  SelectorItem(t.twoTimePillarsView, AbiliaIcons.twoTimelines),
                ],
              ),
            ),
            CollapsableWidget(
              collapsed: !displaySettings.intervalType,
              child: _buildSelector(
                [
                  SelectorItem(t.interval, AbiliaIcons.dayInterval),
                  SelectorItem(t.viewDay, AbiliaIcons.sun),
                  SelectorItem(t.dayAndNight, AbiliaIcons.dayNight),
                ],
              ),
            ),
            CollapsableWidget(
              collapsed: !displaySettings.timepillarZoom,
              child: _buildSelector(
                [
                  SelectorItem(t.small, AbiliaIcons.decreaseText),
                  SelectorItem(t.medium, AbiliaIcons.mediumText),
                  SelectorItem(t.large, AbiliaIcons.enlargeText),
                ],
              ),
            ),
            CollapsableWidget(
              collapsed: !displaySettings.duration,
              child: _buildSelector(
                [
                  SelectorItem(t.dots, AbiliaIcons.options),
                  SelectorItem(t.edge, AbiliaIcons.flarp),
                ],
              ),
            ),
            SwitchField(
              key: TestKey.showTypeOfDisplaySwitch,
              value: displaySettings.calendarType,
              onChanged: (v) => {
                context.read<DayCalendarSettingsCubit>().changeViewOptions(
                      dayCalendarSettings.viewOptions.copyWith(
                        display: displaySettings.copyWith(calendarType: v),
                      ),
                    ),
              },
              child: Text(t.viewMode),
            ).pad(EdgeInsets.fromLTRB(
              layout.templates.m1.left,
              layout.formPadding.groupBottomDistance,
              layout.templates.m1.right,
              0,
            )),
            SwitchField(
              key: TestKey.showTimepillarLengthSwitch,
              value: displaySettings.intervalType,
              onChanged: (v) => {
                context.read<DayCalendarSettingsCubit>().changeViewOptions(
                      dayCalendarSettings.viewOptions.copyWith(
                        display: displaySettings.copyWith(intervalType: v),
                      ),
                    ),
              },
              child: Text(t.dayInterval),
            ).pad(m1ItemPadding),
            SwitchField(
              key: TestKey.showTimelineZoomSwitch,
              value: displaySettings.timepillarZoom,
              onChanged: (v) => {
                context.read<DayCalendarSettingsCubit>().changeViewOptions(
                      dayCalendarSettings.viewOptions.copyWith(
                        display: displaySettings.copyWith(timepillarZoom: v),
                      ),
                    ),
              },
              child: Text(t.timelineZoom),
            ).pad(m1ItemPadding),
            SwitchField(
              key: TestKey.showDurationSelectionSwitch,
              value: displaySettings.duration,
              onChanged: (v) => {
                context.read<DayCalendarSettingsCubit>().changeViewOptions(
                      dayCalendarSettings.viewOptions.copyWith(
                        display: displaySettings.copyWith(duration: v),
                      ),
                    ),
              },
              child: Text(t.activityDuration),
            ).pad(m1ItemPadding),
          ],
        ),
      );
    });
  }

  Widget _buildSelector(List<SelectorItem> items) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: layout.templates.m1.left,
            right: layout.templates.m1.right,
            top: layout.formPadding.verticalItemDistance,
          ),
          child: Selector(
            groupValue: 0,
            items: items,
          ),
        ),
        Divider(
          height: layout.formPadding.groupBottomDistance,
        ),
      ],
    );
  }
}
