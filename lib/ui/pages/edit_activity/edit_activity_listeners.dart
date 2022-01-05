import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ErrorPopupListener extends StatelessWidget {
  final Widget child;

  const ErrorPopupListener({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);

    return BlocListener<ActivityWizardCubit, ActivityWizardState>(
      listenWhen: (_, current) => current.saveErrors.isNotEmpty,
      listener: (context, state) async {
        final errors = state.saveErrors;
        if (errors.noGoErrors) {
          return _noProceed(errors, context, authProviders);
        } else {
          return _inputNeeded(errors, context, authProviders);
        }
      },
      child: child,
    );
  }

  Future _noProceed(
    Set<SaveError> errors,
    BuildContext context,
    List<BlocProvider> authProviders,
  ) async {
    final translate = Translator.of(context).translate;
    showError(String msg) => showViewDialog(
          context: context,
          builder: (context) => ErrorDialog(text: msg),
          authProviders: authProviders,
        );

    if (errors.containsAll({SaveError.noTitleOrImage, SaveError.noStartTime})) {
      return showError(translate.missingTitleOrImageAndStartTime);
    } else if (errors.contains(SaveError.noTitleOrImage)) {
      return showError(translate.missingTitleOrImage);
    } else if (errors.contains(SaveError.noStartTime)) {
      return showError(translate.missingStartTime);
    } else if (errors.contains(SaveError.startTimeBeforeNow)) {
      return showError(translate.startTimeBeforeNowError);
    } else if (errors.contains(SaveError.noRecurringDays)) {
      return showError(translate.recurringDataEmptyErrorMessage);
    } else if (errors.contains(SaveError.endDateBeforeStart)) {
      return showError(translate.endBeforeStartError);
    }
  }

  Future _inputNeeded(
    Set<SaveError> errors,
    BuildContext context,
    List<BlocProvider> authProviders,
  ) async {
    final translate = Translator.of(context).translate;
    SaveRecurring? saveEvent;
    final state = context.read<EditActivityBloc>().state;

    if (errors.contains(SaveError.storedRecurring)) {
      if (state is StoredActivityState) {
        final applyTo = await Navigator.of(context).push<ApplyTo>(
          MaterialPageRoute(
            builder: (_) => SelectRecurrentTypePage(
              heading: translate.editRecurringActivity,
              headingIcon: AbiliaIcons.edit,
              thisDayAndForwardVisible: state.unchangedDate,
            ),
          ),
        );
        if (applyTo == null) return;
        saveEvent = SaveRecurring(applyTo, state.day);
      }
    }
    if (errors.any({
      SaveError.unconfirmedStartTimeBeforeNow,
      SaveError.unconfirmedActivityConflict
    }.contains)) {
      if (errors.contains(SaveError.unconfirmedStartTimeBeforeNow)) {
        final confirmStartTimeBeforeNow = await showViewDialog(
          context: context,
          builder: (context) => ConfirmWarningDialog(
            text: translate.startTimeBeforeNowWarning,
          ),
          authProviders: authProviders,
        );
        if (confirmStartTimeBeforeNow != true) return;
      }

      if (errors.contains(SaveError.unconfirmedActivityConflict)) {
        final confirmConflict = await showViewDialog(
          context: context,
          builder: (context) => ConfirmWarningDialog(
            text: translate.conflictWarning,
          ),
          authProviders: authProviders,
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
        } else if (errors.contains(SaveError.noRecurringDays)) {
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
