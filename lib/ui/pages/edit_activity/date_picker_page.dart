import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class DatePickerPage extends StatelessWidget {
  final DateTime date;
  final DateTime? notBefore;

  const DatePickerPage({
    required this.date,
    Key? key,
    this.notBefore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.selectDate,
        iconData: AbiliaIcons.day,
        bottom: const MonthAppBarStepper(),
      ),
      body: BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState,
          DayColor>(
        selector: (state) => state.settings.calendar.dayColor,
        builder: (context, dayColor) => MonthBody(
          calendarDayColor: dayColor,
          showPreview: false,
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: BlocBuilder<DayPickerBloc, DayPickerState>(
          builder: (context, state) => OkButton(
            onPressed: () async {
              final notBefore = this.notBefore;
              if (notBefore != null && state.day.isDayBefore(notBefore)) {
                return showDialog(
                  context: context,
                  builder: (context) => ErrorDialog(
                    text: Translator.of(context).translate.endBeforeStartError,
                  ),
                );
              }
              Navigator.of(context).pop<DateTime>(state.day);
            },
          ),
        ),
      ),
    );
  }
}
