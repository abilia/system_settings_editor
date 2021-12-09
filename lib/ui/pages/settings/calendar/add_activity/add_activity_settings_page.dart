import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/calendar/add_activity/add_actitivy_default_settings_tab.dart';
import 'package:seagull/ui/pages/settings/calendar/add_activity/add_activity_add_settings_tab.dart';
import 'package:seagull/ui/pages/settings/calendar/add_activity/add_activity_general_settings_tab.dart';

class AddActivitySettingsPage extends StatelessWidget {
  const AddActivitySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocProvider<AddActivitySettingsCubit>(
      create: (context) => AddActivitySettingsCubit(
        settingsState: context.read<MemoplannerSettingBloc>().state,
        genericBloc: context.read<GenericBloc>(),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: Translator.of(context).translate.addActivity,
            iconData: AbiliaIcons.newIcon,
            bottom: AbiliaTabBar(
              tabs: <Widget>[
                TabItem(t.general, AbiliaIcons.settings),
                TabItem(
                  t.add,
                  AbiliaIcons.newIcon,
                  key: TestKey.addSettingsTab,
                ),
                TabItem(t.defaults, AbiliaIcons.technicalSettings),
              ],
            ),
          ),
          body: const TabBarView(children: [
            AddActivityGeneralSettingsTab(),
            AddActivityAddSettingsTab(),
            AddActivityDefaultSettingsTab(),
          ]),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () {
                  context.read<AddActivitySettingsCubit>().save();
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
