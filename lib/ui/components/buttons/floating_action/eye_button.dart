import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class _EyeButton extends StatelessWidget {
  const _EyeButton({Key? key, this.onPressed}) : super(key: key);
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 3,
      shadowColor: AbiliaColors.black,
      borderRadius: borderRadius,
      child: IconActionButtonBlack(
        onPressed: onPressed,
        child: const Icon(AbiliaIcons.show),
        ttsData: Translator.of(context).translate.display,
      ),
    );
  }
}

class EyeButtonDay extends StatelessWidget {
  const EyeButtonDay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => _EyeButton(
        onPressed: () async {
          final settingsBloc = context.read<MemoplannerSettingBloc>();
          final settings = await showViewDialog<EyeButtonSettings?>(
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
              settingsBloc
                  .add(DayCalendarTypeUpdatedEvent(settings.calendarType));
            }
            if (memoSettingsState.dotsInTimepillar !=
                settings.dotsInTimepillar) {
              settingsBloc
                  .add(DotsInTimepillarUpdatedEvent(settings.dotsInTimepillar));
            }
            if (memoSettingsState.timepillarIntervalType !=
                settings.intervalType) {
              settingsBloc.add(IntervalTypeUpdatedEvent(settings.intervalType));
            }
            if (memoSettingsState.timepillarZoom != settings.timepillarZoom) {
              settingsBloc
                  .add(ZoomSettingUpdatedEvent(settings.timepillarZoom));
            }
          }
        },
      ),
    );
  }
}
