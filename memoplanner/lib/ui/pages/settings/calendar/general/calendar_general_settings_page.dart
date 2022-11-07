import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/bloc/all.dart';

class CalendarGeneralSettingsPage extends StatelessWidget {
  const CalendarGeneralSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final settings = context.read<MemoplannerSettingsBloc>().state;
    return BlocProvider<GeneralCalendarSettingsCubit>(
      create: (context) => GeneralCalendarSettingsCubit(
        initial: settings.calendar,
        genericCubit: context.read<GenericCubit>(),
      ),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: t.general,
            label: Config.isMP ? t.calendar : null,
            iconData: AbiliaIcons.settings,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                TabItem(t.clock, AbiliaIcons.clock),
                TabItem(t.intervals, AbiliaIcons.dayInterval),
                TabItem(t.dayColours, AbiliaIcons.changePageColor),
                TabItem(t.categories, AbiliaIcons.calendarList),
              ],
            ),
          ),
          body: const TabBarView(children: [
            ClockSettingsTab(),
            IntervalsSettingsTab(),
            DayColorsSettingsTab(),
            CategoriesSettingsTab(),
          ]),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () async {
                  context.read<GeneralCalendarSettingsCubit>().save();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
