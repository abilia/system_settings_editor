// @dart=2.9

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class DayCalendarSettingsPage extends StatelessWidget {
  const DayCalendarSettingsPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider<DayCalendarSettingsCubit>(
      create: (context) => DayCalendarSettingsCubit(
        settingsState: context.read<MemoplannerSettingBloc>().state,
        genericBloc: context.read<GenericBloc>(),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: Translator.of(context).translate.dayCalendar,
            iconData: AbiliaIcons.day,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                Icon(AbiliaIcons.settings),
                Icon(AbiliaIcons.menu_setup),
                Icon(AbiliaIcons.show),
              ],
            ),
          ),
          body: TabBarView(children: [
            DayAppBarSettingsTab(),
            DayViewSettingsTab(),
            EyeButtonSettingsTab(),
          ]),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: CancelButton(),
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
