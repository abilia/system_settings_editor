import 'dart:math';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class ErrorPopupListener extends StatelessWidget {
  final Widget child;

  const ErrorPopupListener({
    required this.child,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocListener<WizardCubit, WizardState>(
      listenWhen: (_, current) =>
          current.showDialogWarnings && current.saveErrors.isNotEmpty,
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

  Future _noProceed(
    Set<SaveError> errors,
    BuildContext context,
  ) async {
    final translate = Translator.of(context).translate;
    void showError(String msg) => showViewDialog(
          context: context,
          builder: (context) => ErrorDialog(text: msg),
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
    } else if (errors.contains(SaveError.noRecurringEndDate)) {
      return showError(translate.endDateNotSpecifiedErrorMessage);
    }
  }

  Future _inputNeeded(
    Set<SaveError> errors,
    BuildContext context,
  ) async {
    final translate = Translator.of(context).translate;
    SaveRecurring? saveEvent;
    final state = context.read<EditActivityCubit>().state;
    final wizardCubit = context.read<WizardCubit>();

    if (errors.contains(SaveError.storedRecurring)) {
      if (state is StoredActivityState) {
        final applyTo = await Navigator.of(context).push<ApplyTo>(
          PersistentMaterialPageRoute(
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
        // ignore: use_build_context_synchronously
        final confirmStartTimeBeforeNow = await showViewDialog(
          context: context,
          builder: (context) => ConfirmWarningDialog(
            text: translate.startTimeBeforeNowWarning,
          ),
        );
        if (confirmStartTimeBeforeNow != true) return;
      }

      if (errors.contains(SaveError.unconfirmedActivityConflict)) {
        // ignore: use_build_context_synchronously
        final confirmConflict = await showViewDialog(
          context: context,
          builder: (context) => ConfirmWarningDialog(
            text: translate.conflictWarning,
          ),
        );
        if (confirmConflict != true) return;
      }
    }
    wizardCubit.next(
      warningConfirmed: true,
      saveRecurring: saveEvent,
    );
  }
}

class PopOnSaveListener extends StatelessWidget {
  final Widget child;

  const PopOnSaveListener({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocListener<WizardCubit, WizardState>(
        listenWhen: (_, current) => current.successfulSave == true,
        listener: (context, state) => Navigator.of(context).pop(true),
        child: child,
      );
}

class ScrollToErrorPageListener extends StatelessWidget {
  final Widget child;
  final List<EditActivityPageTab> enabledTabs;

  const ScrollToErrorPageListener({
    required this.child,
    required this.enabledTabs,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<WizardCubit, WizardState>(
      listenWhen: (_, current) =>
          current.showDialogWarnings && current.saveErrors.isNotEmpty,
      listener: (context, state) async {
        final errors = state.saveErrors;
        if (errors.mainPageErrors) {
          await _scrollToTab(context, 0);
        } else if (errors.recurringPageErrors) {
          await _scrollToTab(
            context,
            max(enabledTabs.indexOf(EditActivityPageTab.recurrence), 0),
          );
        }
      },
      child: child,
    );
  }

  Future _scrollToTab(BuildContext context, int tabIndex) async {
    final tabController = DefaultTabController.maybeOf(context);
    if (tabController != null && tabController.index != tabIndex) {
      tabController.animateTo(tabIndex);
    } else {
      final sc = PrimaryScrollController.maybeOf(context);
      if (sc != null && sc.hasClients) {
        await sc.animateTo(0.0,
            duration: kTabScrollDuration, curve: Curves.ease);
      }
    }
  }
}
