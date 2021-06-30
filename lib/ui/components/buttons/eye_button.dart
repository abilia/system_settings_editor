// @dart=2.9

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class _EyeButton extends StatelessWidget {
  const _EyeButton({Key key, this.onPressed}) : super(key: key);
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0.s),
      child: Material(
        color: Colors.transparent,
        elevation: 3,
        shadowColor: AbiliaColors.black,
        borderRadius: borderRadius,
        child: ActionButtonBlack(
          onPressed: onPressed,
          child: Icon(AbiliaIcons.show),
        ),
      ),
    );
  }
}

class EyeButton extends StatelessWidget {
  const EyeButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => _EyeButton(
        onPressed: () async {
          final settings = await showViewDialog<EyeButtonSettings>(
            context: context,
            builder: (context) => EyeButtonDayDialog(
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
              context
                  .read<MemoplannerSettingBloc>()
                  .add(DotsInTimepillarUpdatedEvent(settings.dotsInTimepillar));
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
      ),
    );
  }
}

class EyeButtonMonth extends StatelessWidget {
  const EyeButtonMonth({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _EyeButton(
      onPressed: () async {
        final settings = await showViewDialog<MonthCalendarType>(
          context: context,
          builder: (context) => EyeButtonMonthDialog(
            currentCalendarType: MonthCalendarType.grid,
          ),
        );
        if (settings != null) {
          print(settings);
        }
      },
    );
  }
}
