import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class CreateNewPage extends StatelessWidget {
  const CreateNewPage({
    Key? key,
    this.showActivities = true,
    this.showTimers = true,
  })  : assert(showActivities || showTimers),
        assert(!Config.isMPGO || (showActivities && showTimers)),
        super(key: key);

  final bool showActivities, showTimers;

  @override
  Widget build(BuildContext context) {
    final displaysSettings = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.functions.display);
    final displayNewActivity = displaysSettings.newActivity && showActivities;
    final displayNewTimer = displaysSettings.newTimer && showTimers;

    return Scaffold(
      appBar: _appBar(Translator.of(context).translate, displayNewActivity,
          displayNewTimer),
      body: Column(
        children: [
          if (displayNewActivity) const NewActivityWidget(),
          if (displayNewActivity && displayNewTimer)
            const Divider().pad(
              EdgeInsets.only(
                top: layout.formPadding.groupBottomDistance,
              ),
            ),
          if (displayNewTimer) const NewTimerWidget(),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: CancelButton(),
      ),
    );
  }

  AbiliaAppBar _appBar(
    Translated t,
    bool displayNewActivity,
    bool displayNewTimer,
  ) {
    return AbiliaAppBar(
      iconData: Config.isMPGO || displayNewActivity
          ? AbiliaIcons.plus
          : AbiliaIcons.stopWatch,
      title: Config.isMPGO || displayNewTimer && displayNewActivity
          ? t.add
          : displayNewActivity
              ? t.addActivity
              : t.addTimer,
    );
  }
}
