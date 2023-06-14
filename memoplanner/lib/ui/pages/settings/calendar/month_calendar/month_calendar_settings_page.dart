import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class MonthCalendarSettingsPage extends StatelessWidget {
  const MonthCalendarSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Lt.of(context);
    final settings = context.read<MemoplannerSettingsBloc>().state;
    return BlocProvider<MonthCalendarSettingsCubit>(
      create: (context) => MonthCalendarSettingsCubit(
        monthCalendarSettings: settings.monthCalendar,
        genericCubit: context.read<GenericCubit>(),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: t.monthCalendar,
            label: Config.isMP ? t.calendar : null,
            iconData: AbiliaIcons.month,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                TabItem(t.topField, AbiliaIcons.settings),
                TabItem(t.display, AbiliaIcons.menuSetup),
              ],
            ),
          ),
          body: TrackableTabBarView(
            analytics: GetIt.I<SeagullAnalytics>(),
            children: const [
              MonthAppBarSettingsTab(),
              MonthDisplaySettingsTab(),
            ],
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await context.read<MonthCalendarSettingsCubit>().save();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
