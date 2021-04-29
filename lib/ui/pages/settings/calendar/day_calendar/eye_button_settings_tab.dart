import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class EyeButtonSettingsTab extends StatelessWidget {
  const EyeButtonSettingsTab({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettingsState>(
      builder: (context, state) => ListView(
        padding: EdgeInsets.only(top: 20.s, right: 16.s, bottom: 56.s),
        children: [
          Text(t.viewSettings),
          CollapsableWidget(
            collapsed: !state.showTypeOfDisplay,
            child: _buildSelector(
              [
                SelectorItem(t.listView, AbiliaIcons.calendar_list),
                SelectorItem(t.timePillarView, AbiliaIcons.timeline),
              ],
            ),
          ),
          CollapsableWidget(
            collapsed: !state.showTimepillarLength,
            child: _buildSelector(
              [
                SelectorItem(t.interval, AbiliaIcons.day_interval),
                SelectorItem(t.viewDay, AbiliaIcons.sun),
                SelectorItem(t.dayAndNight, AbiliaIcons.day_night),
              ],
            ),
          ),
          CollapsableWidget(
            collapsed: !state.showTimelineZoom,
            child: _buildSelector(
              [
                SelectorItem(t.small, AbiliaIcons.decrease_text),
                SelectorItem(t.medium, AbiliaIcons.decrease_text),
                SelectorItem(t.large, AbiliaIcons.enlarge_text),
              ],
            ),
          ),
          CollapsableWidget(
            collapsed: !state.showDurationSelection,
            child: _buildSelector(
              [
                SelectorItem(t.dots, AbiliaIcons.options),
                SelectorItem(t.edge, AbiliaIcons.flarp),
              ],
            ),
          ),
          SizedBox(height: 8.s),
          SwitchField(
            key: TestKey.showTypeOfDisplaySwitch,
            text: Text(t.typeOfDisplay),
            value: state.showTypeOfDisplay,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showTypeOfDisplay: v),
                  ),
            },
          ),
          SwitchField(
            key: TestKey.showTimepillarLengthSwitch,
            text: Text(t.timelineLength),
            value: state.showTimepillarLength,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showTimepillarLength: v),
                  ),
            },
          ),
          SwitchField(
            key: TestKey.showTimelineZoomSwitch,
            text: Text(t.zoom),
            value: state.showTimelineZoom,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showTimelineZoom: v),
                  ),
            },
          ),
          SwitchField(
            key: TestKey.showDurationSelectionSwitch,
            text: Text(t.activityDuration),
            value: state.showDurationSelection,
            onChanged: (v) => {
              context
                  .read<DayCalendarSettingsCubit>()
                  .changeDayCalendarSettings(
                    state.copyWith(showDurationSelection: v),
                  ),
            },
          ),
        ]
            .map(
              (w) => w is CollapsableWidget
                  ? w
                  : Padding(
                      padding: EdgeInsets.only(left: 12.s, bottom: 8.s),
                      child: w,
                    ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSelector(List<SelectorItem> items) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12.s, top: 8.s),
          child: Selector(
            groupValue: 0,
            items: items,
          ),
        ),
        Divider(endIndent: 0, height: 16.s),
      ],
    );
  }
}
