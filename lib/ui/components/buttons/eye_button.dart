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
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) => ActionButton(
        themeData: blackButtonTheme,
        child: Icon(AbiliaIcons.show),
        onPressed: () async {
          final settings = await showViewDialog<EyeButtonSettings>(
            context: context,
            builder: (context) => EyeButtonDialog(
              currentCalendarType: currentDayCalendarType,
              currentDotsInTimepillar: state.dotsInTimepillar,
            ),
          );
          if (settings != null) {
            if (currentDayCalendarType != settings.calendarType) {
              await BlocProvider.of<CalendarViewBloc>(context)
                  .add(CalendarTypeChanged(settings.calendarType));
            }
            if (state.dotsInTimepillar != settings.dotsInTimepillar) {
              await BlocProvider.of<SettingsBloc>(context)
                  .add(DotsInTimepillarUpdated(settings.dotsInTimepillar));
            }
          }
        },
      ),
    );
  }
}
