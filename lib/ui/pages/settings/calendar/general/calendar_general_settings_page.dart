// @dart=2.9

import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';

class CalendarGeneralSettingsPage extends StatelessWidget {
  const CalendarGeneralSettingsPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocProvider<GeneralCalendarSettingsCubit>(
      create: (context) => GeneralCalendarSettingsCubit(
        settingsState: context.read<MemoplannerSettingBloc>().state,
        genericBloc: context.read<GenericBloc>(),
      ),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: t.general,
            iconData: AbiliaIcons.settings,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                Icon(AbiliaIcons.clock),
                Icon(AbiliaIcons.day_interval),
                Icon(AbiliaIcons.change_page_color),
                Icon(AbiliaIcons.calendar_list),
              ],
            ),
          ),
          body: TabBarView(children: const [
            ClockSettingsTab(),
            IntervalsSettingsTab(),
            DayColorsSettingsTab(),
            CategoriesSettingsTab(),
          ]),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: CancelButton(),
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
