import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MonthCalendarSettingsPage extends StatelessWidget {
  const MonthCalendarSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
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
          body: const TabBarView(children: [
            MonthAppBarSettingsTab(),
            MonthDisplaySettingsTab(),
          ]),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () {
                  context.read<MonthCalendarSettingsCubit>().save();
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
