import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

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
    final dayColor = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayColor);
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.selectDate,
        iconData: AbiliaIcons.day,
        bottom: const MonthAppBarStepper(),
      ),
      body: MonthBody(
        calendarDayColor: dayColor,
        showPreview: false,
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
