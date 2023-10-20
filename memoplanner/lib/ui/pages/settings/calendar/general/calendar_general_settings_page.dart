import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class CalendarGeneralSettingsPage extends StatelessWidget {
  const CalendarGeneralSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
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
            title: translate.general,
            label: Config.isMP ? translate.calendar : null,
            iconData: AbiliaIcons.settings,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                TabItem(translate.clock, AbiliaIcons.clock),
                TabItem(translate.intervals, AbiliaIcons.dayInterval),
                TabItem(translate.dayColours, AbiliaIcons.changePageColor),
                TabItem(translate.categories, AbiliaIcons.calendarList),
              ],
            ),
          ),
          body: TrackableTabBarView(
            analytics: GetIt.I<SeagullAnalytics>(),
            children: const [
              ClockSettingsTab(),
              IntervalsSettingsTab(),
              DayColorsSettingsTab(),
              CategoriesSettingsTab(),
            ],
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await context.read<GeneralCalendarSettingsCubit>().save();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
