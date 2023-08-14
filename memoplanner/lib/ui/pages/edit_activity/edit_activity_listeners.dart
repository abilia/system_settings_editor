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
    final translate = Lt.of(context);
    Future<void> showError(String msg, Set<SaveError> saveErrors) async =>
        showViewDialog(
            context: context,
            builder: (context) => ErrorDialog(text: msg),
            routeSettings: (ErrorDialog).routeSetting(properties: {
              'save errors': saveErrors.map((e) => e.name).toList(),
            }));

    if (errors.containsAll(
        <SaveError>{SaveError.noTitleOrImage, SaveError.noStartTime})) {
      return showError(translate.missingTitleOrImageAndStartTime, errors);
    } else if (errors.contains(SaveError.noTitleOrImage)) {
      return showError(translate.missingTitleOrImage, errors);
    } else if (errors.contains(SaveError.noStartTime)) {
      return showError(translate.missingStartTime, errors);
    } else if (errors.contains(SaveError.startTimeBeforeNow)) {
      return showError(translate.startTimeBeforeNowError, errors);
    } else if (errors.contains(SaveError.noRecurringDays)) {
      return showError(translate.recurringDataEmptyErrorMessage, errors);
    } else if (errors.contains(SaveError.endDateBeforeStart)) {
      return showError(translate.endBeforeStartError, errors);
    } else if (errors.contains(SaveError.noRecurringEndDate)) {
      return showError(translate.endDateNotSpecifiedErrorMessage, errors);
    }
  }

  Future _inputNeeded(
    Set<SaveError> errors,
    BuildContext context,
  ) async {
    SaveRecurring? saveEvent;
    final state = context.read<EditActivityCubit>().state;
    final wizardCubit = context.read<WizardCubit>();

    if (errors.contains(SaveError.storedRecurring) &&
        state is StoredActivityState) {
      final applyTo = await Navigator.of(context).push<ApplyTo>(
        PersistentMaterialPageRoute(
          builder: (_) => SelectRecurrentTypePage(
            heading: Lt.of(context).editRecurringActivity,
            headingIcon: AbiliaIcons.edit,
            thisDayAndForwardVisible: state.unchangedDate,
          ),
          settings: (SelectRecurrentTypePage).routeSetting(),
        ),
      );
      if (applyTo == null) return;
      saveEvent = SaveRecurring(applyTo, state.day);
    }

    if (errors.contains(SaveError.unconfirmedStartTimeBeforeNow) &&
        (saveEvent == null || saveEvent.applyTo == ApplyTo.onlyThisDay) &&
        context.mounted) {
      final confirmStartTimeBeforeNow = await showViewDialog(
        context: context,
        builder: (context) => const ConfirmStartTimeBeforeNowWarningDialog(),
        routeSettings: (ConfirmStartTimeBeforeNowWarningDialog).routeSetting(),
      );
      if (confirmStartTimeBeforeNow != true) return;
    }
    if (errors.contains(SaveError.unconfirmedActivityConflict) &&
        context.mounted) {
      final confirmConflict = await showViewDialog(
        context: context,
        builder: (context) => const ConfirmConflictWarningDialog(),
        routeSettings: (ConfirmConflictWarningDialog).routeSetting(),
      );
      if (confirmConflict != true) return;
    }
    wizardCubit.next(
      warningConfirmed: true,
      saveRecurring: saveEvent,
    );
  }
}

class ConfirmConflictWarningDialog extends StatelessWidget {
  const ConfirmConflictWarningDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ConfirmWarningDialog(
        text: Lt.of(context).conflictWarning,
      );
}

class ConfirmStartTimeBeforeNowWarningDialog extends StatelessWidget {
  const ConfirmStartTimeBeforeNowWarningDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ConfirmWarningDialog(
        text: Lt.of(context).startTimeBeforeNowWarning,
      );
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
