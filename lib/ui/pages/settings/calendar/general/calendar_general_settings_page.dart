import 'package:seagull/ui/all.dart';
import 'package:seagull/bloc/all.dart';

class CalendarGeneralSettingsPage extends StatelessWidget {
  const CalendarGeneralSettingsPage({Key? key}) : super(key: key);
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
            bottom: const AbiliaTabBar(
              tabs: <Widget>[
                Icon(AbiliaIcons.clock),
                Icon(AbiliaIcons.dayInterval),
                Icon(AbiliaIcons.changePageColor),
                Icon(AbiliaIcons.calendarList),
              ],
            ),
          ),
          body: const TabBarView(children: [
            ClockSettingsTab(),
            IntervalsSettingsTab(),
            DayColorsSettingsTab(),
            CategoriesSettingsTab(),
          ]),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
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
