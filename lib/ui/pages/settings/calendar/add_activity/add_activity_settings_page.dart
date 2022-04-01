import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AddActivitySettingsPage extends StatelessWidget {
  const AddActivitySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocProvider<AddActivitySettingsCubit>(
      create: (context) => AddActivitySettingsCubit(
        settingsState: context.read<MemoplannerSettingBloc>().state,
        genericCubit: context.read<GenericCubit>(),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AbiliaAppBar(
            title: t.addActivity,
            label: Config.isMP ? t.calendar : null,
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
