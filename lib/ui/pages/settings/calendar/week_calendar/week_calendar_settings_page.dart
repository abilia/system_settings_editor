import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class WeekCalendarSettings extends StatelessWidget {
  const WeekCalendarSettings({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider<WeekCalendarSettingsCubit>(
      create: (context) => WeekCalendarSettingsCubit(
        settingsState: context.read<MemoplannerSettingBloc>().state,
        genericBloc: context.read<GenericBloc>(),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: Translator.of(context).translate.weekCalendar,
            iconData: AbiliaIcons.week,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                Icon(AbiliaIcons.settings),
                Icon(AbiliaIcons.menu_setup),
              ],
            ),
          ),
          body: TabBarView(children: [
            WeekAppBarSettingsTab(),
            WeekSettingsTab(),
          ]),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () {
                  context.read<WeekCalendarSettingsCubit>().save();
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
