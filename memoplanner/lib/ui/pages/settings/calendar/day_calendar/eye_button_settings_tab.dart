import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class EyeButtonSettingsTab extends StatelessWidget {
  const EyeButtonSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
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
            Tts(child: Text(translate.viewSettings)).pad(
              layout.templates.m1.onlyHorizontal,
            ),
            CollapsableWidget(
              collapsed: !displaySettings.calendarType,
              child: _buildSelector(
                [
                  SelectorItem(translate.listView, AbiliaIcons.calendarList),
                  SelectorItem(
                      translate.oneTimePillarView, AbiliaIcons.timeline),
                  SelectorItem(
                      translate.twoTimePillarsView, AbiliaIcons.twoTimelines),
                ],
              ),
            ),
            CollapsableWidget(
              collapsed: !displaySettings.intervalType,
              child: _buildSelector(
                [
                  SelectorItem(translate.interval, AbiliaIcons.dayInterval),
                  SelectorItem(translate.viewDay, AbiliaIcons.sun),
                  SelectorItem(translate.dayAndNight, AbiliaIcons.dayNight),
                ],
              ),
            ),
            CollapsableWidget(
              collapsed: !displaySettings.timepillarZoom,
              child: _buildSelector(
                [
                  SelectorItem(translate.small, AbiliaIcons.decreaseText),
                  SelectorItem(translate.medium, AbiliaIcons.mediumText),
                  SelectorItem(translate.large, AbiliaIcons.enlargeText),
                ],
              ),
            ),
            CollapsableWidget(
              collapsed: !displaySettings.duration,
              child: _buildSelector(
                [
                  SelectorItem(translate.dots, AbiliaIcons.options),
                  SelectorItem(translate.edge, AbiliaIcons.flarp),
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
              child: Text(translate.viewMode),
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
              child: Text(translate.dayInterval),
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
              child: Text(translate.timelineZoom),
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
              child: Text(translate.activityDuration),
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
