import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ErrorPopupListener extends StatelessWidget {
  final Widget child;

  const ErrorPopupListener({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityWizardCubit, ActivityWizardState>(
      listenWhen: (_, current) => current.saveErrors.isNotEmpty,
      listener: (context, state) async {
        final errors = state.saveErrors;
        if (errors.noGoErrors) {
          return _noProceed(errors, context);
        } else {
          return _inputNeeded(errors, context);
        }
      },
      child: child,
    );
  }

  Future _noProceed(Set<SaveError> errors, BuildContext context) async {
    final translate = Translator.of(context).translate;
    showError(String msg) => showViewDialog(
          context: context,
          builder: (context) => ErrorDialog(text: msg),
        );

    if (errors
        .containsAll({SaveError.NO_TITLE_OR_IMAGE, SaveError.NO_START_TIME})) {
      return showError(translate.missingTitleOrImageAndStartTime);
    } else if (errors.contains(SaveError.NO_TITLE_OR_IMAGE)) {
      return showError(translate.missingTitleOrImage);
    } else if (errors.contains(SaveError.NO_START_TIME)) {
      return showError(translate.missingStartTime);
    } else if (errors.contains(SaveError.START_TIME_BEFORE_NOW)) {
      return showError(translate.startTimeBeforeNowError);
    } else if (errors.contains(SaveError.NO_RECURRING_DAYS)) {
      return showError(translate.recurringDataEmptyErrorMessage);
    } else if (errors.contains(SaveError.END_DATE_BEFORE_START)) {
      return showError(translate.endBeforeStartError);
    }
  }

  Future _inputNeeded(Set<SaveError> errors, BuildContext context) async {
    final translate = Translator.of(context).translate;
    SaveRecurring? saveEvent;
    final state = context.read<EditActivityBloc>().state;

    if (errors.contains(SaveError.STORED_RECURRING)) {
      if (state is StoredActivityState) {
        final applyTo = await Navigator.of(context).push<ApplyTo>(
          MaterialPageRoute(
            builder: (_) => SelectRecurrentTypePage(
              heading: translate.editRecurringActivity,
              headingIcon: AbiliaIcons.edit,
            ),
          ),
        );
        if (applyTo == null) return;
        saveEvent = SaveRecurring(applyTo, state.day);
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
    }
    context.read<ActivityWizardCubit>().next(
          warningConfirmed: true,
          saveRecurring: saveEvent,
        );
  }
}

class PopOnSaveListener extends StatelessWidget {
  final Widget child;

  const PopOnSaveListener({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocListener<ActivityWizardCubit, ActivityWizardState>(
        listenWhen: (_, current) => current.sucessfullSave == true,
        listener: (context, state) => Navigator.of(context).pop(true),
        child: child,
      );
}

class ScrollToErrorPageListener extends StatelessWidget {
  final int nrTabs;
  final Widget child;

  const ScrollToErrorPageListener({
    Key? key,
    required this.nrTabs,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityWizardCubit, ActivityWizardState>(
      listenWhen: (_, current) => current.saveErrors.isNotEmpty,
      listener: (context, state) async {
        final errors = state.saveErrors;
        if (errors.mainPageErrors) {
          await _scrollToTab(context, 0);
        } else if (errors.contains(SaveError.NO_RECURRING_DAYS)) {
          await _scrollToTab(context, nrTabs - 2);
        }
      },
      child: child,
    );
  }

  Future _scrollToTab(BuildContext context, int tabIndex) async {
    final tabController = DefaultTabController.of(context);
    if (tabController != null && tabController.index != tabIndex) {
      tabController.animateTo(tabIndex);
    } else {
      final sc = PrimaryScrollController.of(context);
      if (sc != null && sc.hasClients) {
        await sc.animateTo(0.0,
            duration: kTabScrollDuration, curve: Curves.ease);
      }
    }
  }
}
