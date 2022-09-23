import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class WeekCalendarSettingsPage extends StatelessWidget {
  const WeekCalendarSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocProvider<WeekCalendarSettingsCubit>(
      create: (context) => WeekCalendarSettingsCubit(
        weekCalendarSettings:
            context.read<MemoplannerSettingBloc>().state.settings.weekCalendar,
        genericCubit: context.read<GenericCubit>(),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: t.weekCalendar,
            label: Config.isMP ? t.calendar : null,
            iconData: AbiliaIcons.week,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                TabItem(t.topField, AbiliaIcons.settings),
                TabItem(t.display, AbiliaIcons.menuSetup),
              ],
            ),
          ),
          body: const TabBarView(children: [
            WeekAppBarSettingsTab(),
            WeekSettingsTab(),
          ]),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
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
