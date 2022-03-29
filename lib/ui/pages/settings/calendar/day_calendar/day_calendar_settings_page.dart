import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class DayCalendarSettingsPage extends StatelessWidget {
  const DayCalendarSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocProvider<DayCalendarSettingsCubit>(
      create: (context) => DayCalendarSettingsCubit(
        settingsState: context.read<MemoplannerSettingBloc>().state,
        genericCubit: context.read<GenericCubit>(),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: t.dayCalendar,
            label: t.calendar,
            iconData: AbiliaIcons.day,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                TabItem(t.topField, AbiliaIcons.settings),
                TabItem(t.display, AbiliaIcons.menuSetup),
                TabItem(t.view, AbiliaIcons.show),
              ],
            ),
          ),
          body: const TabBarView(children: [
            DayAppBarSettingsTab(),
            DayViewSettingsTab(),
            EyeButtonSettingsTab(),
          ]),
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
