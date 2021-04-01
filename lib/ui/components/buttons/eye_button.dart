import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EyeButton extends StatelessWidget {
  const EyeButton({
    Key key,
    @required this.currentDayCalendarType,
  }) : super(key: key);

  final DayCalendarType currentDayCalendarType;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) =>
          BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) => Material(
          color: Colors.transparent,
          elevation: 3,
          shadowColor: AbiliaColors.black,
          borderRadius: borderRadius,
          child: ActionButtonBlack(
            onPressed: () async {
              final settings = await showViewDialog<EyeButtonSettings>(
                context: context,
                builder: (context) => EyeButtonDialog(
                  currentCalendarType: currentDayCalendarType,
                  currentDotsInTimepillar: state.dotsInTimepillar,
                  currentDayInterval: memoSettingsState.timepillarIntervalType,
                  currentZoom: memoSettingsState.timepillarZoom,
                ),
              );
              if (settings != null) {
                if (currentDayCalendarType != settings.calendarType) {
                  BlocProvider.of<CalendarViewBloc>(context)
                      .add(CalendarTypeChanged(settings.calendarType));
                }
                if (state.dotsInTimepillar != settings.dotsInTimepillar) {
                  BlocProvider.of<SettingsBloc>(context)
                      .add(DotsInTimepillarUpdated(settings.dotsInTimepillar));
                }
                if (memoSettingsState.timepillarIntervalType !=
                    settings.intervalType) {
                  context
                      .read<MemoplannerSettingBloc>()
                      .add(IntervalTypeUpdatedEvent(settings.intervalType));
                }
                if (memoSettingsState.timepillarZoom !=
                    settings.timepillarZoom) {
                  context
                      .read<MemoplannerSettingBloc>()
                      .add(ZoomSettingUpdatedEvent(settings.timepillarZoom));
                }
              }
            },
            child: Icon(AbiliaIcons.show),
          ),
        ),
      ),
    );
  }
}
