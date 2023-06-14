import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class AddActivitySettingsPage extends StatelessWidget {
  const AddActivitySettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Lt.of(context);
    final settings = context.read<MemoplannerSettingsBloc>().state;
    return BlocProvider<AddActivitySettingsCubit>(
      create: (context) => AddActivitySettingsCubit(
        addActivitySettings: settings.addActivity,
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
                TabItem(
                  t.add,
                  AbiliaIcons.newIcon,
                  key: TestKey.addSettingsTab,
                ),
                TabItem(t.general, AbiliaIcons.settings),
                TabItem(t.defaults, AbiliaIcons.technicalSettings),
              ],
            ),
          ),
          body: TrackableTabBarView(
            analytics: GetIt.I<SeagullAnalytics>(),
            children: const [
              AddActivityAddSettingsTab(),
              AddActivityGeneralSettingsTab(),
              AddActivityDefaultSettingsTab(),
            ],
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: const CancelButton(),
            forwardNavigationWidget: Builder(
              builder: (context) => OkButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await context.read<AddActivitySettingsCubit>().save();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
