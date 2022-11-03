import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

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
        ttsData: Translator.of(context).translate.display,
        child: const Icon(AbiliaIcons.show),
      ),
    );
  }
}

class EyeButtonDay extends StatelessWidget {
  const EyeButtonDay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _EyeButton(
      onPressed: () async {
        final settingsBloc = context.read<MemoplannerSettingsBloc>();
        final viewOptions = settingsBloc.state.dayCalendar.viewOptions;
        final settings = await showViewDialog<EyeButtonSettings?>(
          context: context,
          builder: (context) => EyeButtonDayDialog(
            currentCalendarType: viewOptions.calendarType,
            currentDotsInTimepillar: viewOptions.dots,
            currentDayInterval: viewOptions.intervalType,
            currentZoom: viewOptions.timepillarZoom,
          ),
        );
        if (settings != null) {
          if (viewOptions.calendarType != settings.calendarType) {
            settingsBloc
                .add(DayCalendarTypeUpdatedEvent(settings.calendarType));
          }
          if (viewOptions.dots != settings.dotsInTimepillar) {
            settingsBloc
                .add(DotsInTimepillarUpdatedEvent(settings.dotsInTimepillar));
          }
          if (viewOptions.intervalType != settings.intervalType) {
            settingsBloc.add(IntervalTypeUpdatedEvent(settings.intervalType));
          }
          if (viewOptions.timepillarZoom != settings.timepillarZoom) {
            settingsBloc.add(ZoomSettingUpdatedEvent(settings.timepillarZoom));
          }
        }
      },
    );
  }
}
