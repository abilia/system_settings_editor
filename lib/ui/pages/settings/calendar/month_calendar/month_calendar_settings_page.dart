import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MonthCalendarSettingsPage extends StatelessWidget {
  const MonthCalendarSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider<MonthCalendarSettingsCubit>(
      create: (context) => MonthCalendarSettingsCubit(
        settingsState: context.read<MemoplannerSettingBloc>().state,
        genericBloc: context.read<GenericBloc>(),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: Translator.of(context).translate.monthCalendar,
            iconData: AbiliaIcons.month,
            bottom: const AbiliaTabBar(
              tabs: <Widget>[
                Icon(AbiliaIcons.settings),
                Icon(AbiliaIcons.menuSetup),
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
