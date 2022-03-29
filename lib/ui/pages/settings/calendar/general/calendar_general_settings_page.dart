import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';

class CalendarGeneralSettingsPage extends StatelessWidget {
  const CalendarGeneralSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocProvider<GeneralCalendarSettingsCubit>(
      create: (context) => GeneralCalendarSettingsCubit(
        settingsState: context.read<MemoplannerSettingBloc>().state,
        genericCubit: context.read<GenericCubit>(),
      ),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: t.general,
            label: t.calendar,
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
