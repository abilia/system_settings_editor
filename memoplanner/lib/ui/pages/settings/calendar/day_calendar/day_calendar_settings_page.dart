import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class DayCalendarSettingsPage extends StatelessWidget {
  const DayCalendarSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final settings = context.read<MemoplannerSettingsBloc>().state;
    return BlocProvider<DayCalendarSettingsCubit>(
      create: (context) => DayCalendarSettingsCubit(
        dayCalendarSettings: settings.dayCalendar,
        genericCubit: context.read<GenericCubit>(),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: t.dayCalendar,
            label: Config.isMP ? t.calendar : null,
            iconData: AbiliaIcons.day,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                TabItem(t.topField, AbiliaIcons.settings),
                TabItem(t.display, AbiliaIcons.menuSetup),
                TabItem(t.view, AbiliaIcons.show),
              ],
            ),
          ),
          body: TrackableTabBarView(
            analytics: GetIt.I<SeagullAnalytics>(),
            children: const [
              DayAppBarSettingsTab(),
              DayViewSettingsTab(),
              EyeButtonSettingsTab(),
            ],
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () {
                  context.read<DayCalendarSettingsCubit>().save();
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
