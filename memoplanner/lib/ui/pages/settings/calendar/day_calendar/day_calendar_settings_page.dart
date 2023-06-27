import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class DayCalendarSettingsPage extends StatelessWidget {
  const DayCalendarSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final settings = context.read<MemoplannerSettingsBloc>().state;
    return BlocProvider<DayCalendarSettingsCubit>(
      create: (context) => DayCalendarSettingsCubit(
        dayAppBarSettings: settings.dayAppBar,
        dayCalendarViewCubit: context.read<DayCalendarViewCubit>(),
        genericCubit: context.read<GenericCubit>(),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: translate.dayCalendar,
            label: Config.isMP ? translate.calendar : null,
            iconData: AbiliaIcons.day,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                TabItem(translate.topField, AbiliaIcons.settings),
                TabItem(translate.display, AbiliaIcons.menuSetup),
                TabItem(translate.view, AbiliaIcons.show),
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
                onPressed: () async {
                  Navigator.of(context).pop();
                  await context.read<DayCalendarSettingsCubit>().save();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
