import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class EditActivityPage extends StatelessWidget {
  final DateTime day;
  final String title;
  const EditActivityPage({
    @required this.day,
    this.title,
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) =>
          BlocBuilder<EditActivityBloc, EditActivityState>(
        builder: (context, state) {
          final activity = state.activity;
          final fullDay = activity.fullDay;
          final displayRecurrence = memoSettingsState.activityRecurringEditable;
          final tabs = [
            MainTab(
              editActivityState: state,
              memoplannerSettingsState: memoSettingsState,
              day: day,
            ),
            if (!fullDay) AlarmAndReminderTab(activity: activity),
            if (displayRecurrence) RecurrenceTab(state: state),
            InfoItemTab(state: state),
          ];
          return DefaultTabController(
            initialIndex: 0,
            length: tabs.length,
            child: Scaffold(
              appBar: NewAbiliaAppBar(
                iconData: AbiliaIcons.plus,
                title: translate.newActivity,
                bottom: AbiliaTabBar(
                  collapsedCondition: (i) {
                    switch (i) {
                      case 1:
                        return fullDay;
                      case 2:
                        return !displayRecurrence;
                      default:
                        return false;
                    }
                  },
                  tabs: <Widget>[
                    Icon(AbiliaIcons.my_photos),
                    Icon(AbiliaIcons.attention),
                    Icon(AbiliaIcons.repeat),
                    Icon(AbiliaIcons.attachment),
                  ],
                ),
              ),
              body: EditActivityListeners(
                child: TabBarView(children: tabs),
                nrTabs: tabs.length,
              ),
              bottomNavigationBar: BottomNavigation(
                backNavigationWidget: const BackButton(),
                forwardNavigationWidget: GreenButton(
                  key: TestKey.finishEditActivityButton,
                  icon: AbiliaIcons.ok,
                  text: translate.save,
                  onPressed: () => BlocProvider.of<EditActivityBloc>(context)
                      .add(SaveActivity()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditActivityListeners extends StatelessWidget {
  final Widget child;
  final int nrTabs;

  const EditActivityListeners({
    Key key,
    @required this.child,
    @required this.nrTabs,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EditActivityBloc, EditActivityState>(
          listenWhen: (_, current) => current.sucessfullSave == true,
          listener: (context, state) => Navigator.of(context).maybePop(true),
        ),
        BlocListener<EditActivityBloc, EditActivityState>(
          listenWhen: (_, current) => current.saveErrors.isNotEmpty,
          listener: (context, state) async {
            final errors = state.saveErrors;
            if (errors.any(
              {
                SaveError.NO_TITLE_OR_IMAGE,
                SaveError.NO_START_TIME,
                SaveError.START_TIME_BEFORE_NOW,
              }.contains,
            )) {
              return await _mainPageError(errors, context);
            } else if (errors.contains(SaveError.NO_RECURRING_DAYS)) {
              _scrollToTab(context, nrTabs - 2);
              return await showViewDialog(
                context: context,
                builder: (context) => ErrorDialog(
                  text: Translator.of(context)
                      .translate
                      .recurringDataEmptyErrorMessage,
                ),
              );
            } else if (errors.contains(SaveError.STORED_RECURRING)) {
              if (state is StoredActivityState) {
                final applyTo =
                    await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SelectRecurrentTypePage(
                    heading:
                        Translator.of(context).translate.editRecurringActivity,
                    headingIcon: AbiliaIcons.edit,
                  ),
                ));
                if (applyTo == null) return;
                BlocProvider.of<EditActivityBloc>(context)
                    .add(SaveRecurringActivity(applyTo, state.day));
              }
            }
          },
        )
      ],
      child: child,
    );
  }

  Future _mainPageError(Set<SaveError> errors, BuildContext context) async {
    final translate = Translator.of(context).translate;
    await _scrollToTab(context, 0);
    var text = '';

    if (errors.containsAll(
      {
        SaveError.NO_TITLE_OR_IMAGE,
        SaveError.NO_START_TIME,
      },
    )) {
      text = translate.missingTitleOrImageAndStartTime;
    } else if (errors.contains(SaveError.NO_TITLE_OR_IMAGE)) {
      text = translate.missingTitleOrImage;
    } else if (errors.contains(SaveError.NO_START_TIME)) {
      text = translate.missingStartTime;
    } else if (errors.contains(SaveError.START_TIME_BEFORE_NOW)) {
      text = translate.startTimeBeforeNow;
    }
    assert(text.isNotEmpty);
    return showViewDialog(
      context: context,
      builder: (context) => ErrorDialog(text: text),
    );
  }

  void _scrollToTab(BuildContext context, int tabIndex) {
    final tabController = DefaultTabController.of(context);
    if (tabController.index != tabIndex) {
      tabController.animateTo(tabIndex);
    } else {
      final sc = PrimaryScrollController.of(context);
      if (sc?.hasClients == true) {
        sc.animateTo(0.0, duration: kTabScrollDuration, curve: Curves.ease);
      }
    }
  }
}
