import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class DatePickerPage extends StatelessWidget {
  final DateTime date;

  const DatePickerPage({
    Key key,
    this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: MonthCalendarBloc(
            clockBloc: context.read<ClockBloc>(),
            initialDay: date,
          ),
        ),
        BlocProvider.value(
          value: DayPickerBloc(
            clockBloc: context.read<ClockBloc>(),
            initialDay: date,
          ),
        ),
      ],
      child: Scaffold(
        appBar: AbiliaAppBar(
          title: Translator.of(context).translate.selectDate,
          iconData: AbiliaIcons.day,
          bottom: const MonthAppBarStepper(),
        ),
        body: const MonthBody(),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget: const CancelButton(),
          forwardNavigationWidget: BlocBuilder<DayPickerBloc, DayPickerState>(
            builder: (context, state) => OkButton(
              onPressed: () => Navigator.of(context).pop<DateTime>(state.day),
            ),
          ),
        ),
      ),
    );
  }
}
