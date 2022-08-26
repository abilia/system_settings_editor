import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class EyeButtonSettingsTab extends StatelessWidget {
  const EyeButtonSettingsTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final scrollController = ScrollController();
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettingsState>(
      builder: (context, state) => ScrollArrows.vertical(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          padding: layout.templates.m1.onlyVertical,
          children: [
            CollapsableWidget(
              collapsed: !state.showTypeOfDisplay,
              child: _buildSelector(
                t.viewMode,
                [
                  SelectorItem(t.listView, AbiliaIcons.calendarList),
                  SelectorItem(t.oneTimePillarView, AbiliaIcons.timeline),
                  SelectorItem(t.twoTimePillarsView, AbiliaIcons.twoTimelines),
                ],
              ),
            ),
            CollapsableWidget(
              collapsed: !state.showTimepillarLength,
              child: _buildSelector(
                t.dayInterval,
                [
                  SelectorItem(t.interval, AbiliaIcons.dayInterval),
                  SelectorItem(t.viewDay, AbiliaIcons.sun),
                  SelectorItem(t.dayAndNight, AbiliaIcons.dayNight),
                ],
              ),
            ),
            CollapsableWidget(
              collapsed: !state.showTimelineZoom,
              child: _buildSelector(
                t.zoom,
                [
                  SelectorItem(t.small, AbiliaIcons.decreaseText),
                  SelectorItem(t.medium, AbiliaIcons.mediumText),
                  SelectorItem(t.large, AbiliaIcons.enlargeText),
                ],
              ),
            ),
            CollapsableWidget(
              collapsed: !state.showDurationSelection,
              child: _buildSelector(
                t.duration,
                [
                  SelectorItem(t.dots, AbiliaIcons.options),
                  SelectorItem(t.edge, AbiliaIcons.flarp),
                ],
              ),
            ),
            SwitchField(
              key: TestKey.showTypeOfDisplaySwitch,
              value: state.showTypeOfDisplay,
              onChanged: (v) => {
                context
                    .read<DayCalendarSettingsCubit>()
                    .changeDayCalendarSettings(
                      state.copyWith(showTypeOfDisplay: v),
                    ),
              },
              child: Text(t.typeOfDisplay),
            ).pad(EdgeInsets.fromLTRB(
              layout.templates.m1.left,
              layout.formPadding.groupBottomDistance,
              layout.templates.m1.right,
              0,
            )),
            SwitchField(
              key: TestKey.showTimepillarLengthSwitch,
              value: state.showTimepillarLength,
              onChanged: (v) => {
                context
                    .read<DayCalendarSettingsCubit>()
                    .changeDayCalendarSettings(
                      state.copyWith(showTimepillarLength: v),
                    ),
              },
              child: Text(t.timelineLength),
            ).pad(m1ItemPadding),
            SwitchField(
              key: TestKey.showTimelineZoomSwitch,
              value: state.showTimelineZoom,
              onChanged: (v) => {
                context
                    .read<DayCalendarSettingsCubit>()
                    .changeDayCalendarSettings(
                      state.copyWith(showTimelineZoom: v),
                    ),
              },
              child: Text(t.zoom),
            ).pad(m1ItemPadding),
            SwitchField(
              key: TestKey.showDurationSelectionSwitch,
              value: state.showDurationSelection,
              onChanged: (v) => {
                context
                    .read<DayCalendarSettingsCubit>()
                    .changeDayCalendarSettings(
                      state.copyWith(showDurationSelection: v),
                    ),
              },
              child: Text(t.activityDuration),
            ).pad(m1ItemPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector(String title, List<SelectorItem> items) {
    return Column(
      children: [
        Center(
          child: Tts(
            child: Text(
              title,
              style: (bodyText2).copyWith(
                color: AbiliaColors.black75,
              ),
            ),
          ).pad(
            layout.templates.m1.onlyHorizontal,
          ),
        ),
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
