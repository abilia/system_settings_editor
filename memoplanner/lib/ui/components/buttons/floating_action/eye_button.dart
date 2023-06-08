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
        final dayCalendarViewCubit = context.read<DayCalendarViewCubit>();
        final viewOptions = dayCalendarViewCubit.state;
        final settings = await showViewDialog<EyeButtonSettings?>(
            context: context,
            builder: (context) => EyeButtonDayDialog(
                  currentCalendarType: viewOptions.calendarType,
                  currentDotsInTimepillar: viewOptions.dots,
                  currentDayInterval: viewOptions.intervalType,
                  currentZoom: viewOptions.timepillarZoom,
                ),
            routeSettings: (EyeButtonDayDialog).routeSetting(properties: {
              'currentCalendarType': viewOptions.calendarType.name,
              'currentDotsInTimepillar': viewOptions.dots,
              'currentDayInterval': viewOptions.intervalType.name,
              'currentZoom': viewOptions.timepillarZoom.name,
            }));
        if (settings != null) {
          await dayCalendarViewCubit.setDayCalendarViewOptionsSettings(
            DayCalendarViewSettings(
              dots: settings.dotsInTimepillar,
              calendarTypeIndex: settings.calendarType.index,
              intervalTypeIndex: settings.intervalType.index,
              timepillarZoomIndex: settings.timepillarZoom.index,
            ),
          );
        }
      },
    );
  }
}
