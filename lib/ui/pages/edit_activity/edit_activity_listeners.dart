import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

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
          listener: (context, state) => Navigator.of(context).pop(true),
        ),
        BlocListener<EditActivityBloc, EditActivityState>(
          listenWhen: (_, current) => current.saveErrors.isNotEmpty,
          listener: (context, state) async {
            final errors = state.saveErrors;
            if (errors.any(EditActivityBloc.NO_GO_ERRORS.contains)) {
              return _noProceed(errors, context);
            } else {
              return _inputNeeded(errors, state, context);
            }
          },
        )
      ],
      child: child,
    );
  }

  Future _noProceed(Set<SaveError> errors, BuildContext context) async {
    if (errors.any(
      {
        SaveError.NO_TITLE_OR_IMAGE,
        SaveError.NO_START_TIME,
        SaveError.START_TIME_BEFORE_NOW,
      }.contains,
    )) {
      return await _mainPageError(errors, context);
    } else if (errors.contains(SaveError.NO_RECURRING_DAYS)) {
      await _scrollToTab(context, nrTabs - 2);
      return await showViewDialog(
        context: context,
        builder: (context) => ErrorDialog(
          text: Translator.of(context).translate.recurringDataEmptyErrorMessage,
        ),
      );
    }
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
      text = translate.startTimeBeforeNowError;
    }
    assert(text.isNotEmpty);
    return showViewDialog(
      context: context,
      builder: (context) => ErrorDialog(text: text),
    );
  }

  Future _scrollToTab(BuildContext context, int tabIndex) async {
    final tabController = DefaultTabController.of(context);
    if (tabController.index != tabIndex) {
      tabController.animateTo(tabIndex);
    } else {
      final sc = PrimaryScrollController.of(context);
      if (sc?.hasClients == true) {
        await sc.animateTo(0.0,
            duration: kTabScrollDuration, curve: Curves.ease);
      }
    }
  }

  Future _inputNeeded(Set<SaveError> errors, EditActivityState state,
      BuildContext context) async {
    final translate = Translator.of(context).translate;
    if (errors.contains(SaveError.STORED_RECURRING)) {
      if (state is StoredActivityState) {
        final applyTo = await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => SelectRecurrentTypePage(
            heading: translate.editRecurringActivity,
            headingIcon: AbiliaIcons.edit,
          ),
        ));
        if (applyTo == null) return;
        BlocProvider.of<EditActivityBloc>(context)
            .add(SaveRecurringActivity(applyTo, state.day));
      }
    }
    if (errors.any({
      SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW,
      SaveError.UNCONFIRMED_ACTIVITY_CONFLICT
    }.contains)) {
      if (errors.contains(SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW)) {
        final confirmStartTimeBeforeNow = await showViewDialog(
          context: context,
          builder: (context) => WarningDialog(
            text: translate.startTimeBeforeNowWarning,
          ),
        );
        if (confirmStartTimeBeforeNow != true) return;
      }

      if (errors.contains(SaveError.UNCONFIRMED_ACTIVITY_CONFLICT)) {
        final confirmConflict = await showViewDialog(
          context: context,
          builder: (context) => WarningDialog(
            text: translate.conflictWarning,
          ),
        );
        if (confirmConflict != true) return;
      }

      BlocProvider.of<EditActivityBloc>(context).add(
        SaveActivity(
          warningConfirmed: true,
        ),
      );
    }
  }
}
