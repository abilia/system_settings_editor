// @dart=2.9

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EyeButton extends StatelessWidget {
  const EyeButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => Material(
        color: Colors.transparent,
        elevation: 3,
        shadowColor: AbiliaColors.black,
        borderRadius: borderRadius,
        child: ActionButtonBlack(
          onPressed: () async {
            final settings = await showViewDialog<EyeButtonSettings>(
              context: context,
              builder: (context) => EyeButtonDialog(
                currentCalendarType: memoSettingsState.dayCalendarType,
                currentDotsInTimepillar: memoSettingsState.dotsInTimepillar,
                currentDayInterval: memoSettingsState.timepillarIntervalType,
                currentZoom: memoSettingsState.timepillarZoom,
              ),
            );
            if (settings != null) {
              if (memoSettingsState.dayCalendarType != settings.calendarType) {
                context
                    .read<MemoplannerSettingBloc>()
                    .add(DayCalendarTypeUpdatedEvent(settings.calendarType));
              }
              if (memoSettingsState.dotsInTimepillar !=
                  settings.dotsInTimepillar) {
                context.read<MemoplannerSettingBloc>().add(
                    DotsInTimepillarUpdatedEvent(settings.dotsInTimepillar));
              }
              if (memoSettingsState.timepillarIntervalType !=
                  settings.intervalType) {
                context
                    .read<MemoplannerSettingBloc>()
                    .add(IntervalTypeUpdatedEvent(settings.intervalType));
              }
              if (memoSettingsState.timepillarZoom != settings.timepillarZoom) {
                context
                    .read<MemoplannerSettingBloc>()
                    .add(ZoomSettingUpdatedEvent(settings.timepillarZoom));
              }
            }
          },
          child: Icon(AbiliaIcons.show),
        ),
      ),
    );
  }
}
