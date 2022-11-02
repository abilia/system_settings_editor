import 'dart:collection';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class TemplateActivityWizardCubit extends WizardCubit {
  final EditActivityCubit editActivityCubit;
  final SortableBloc sortableBloc;
  final Sortable<BasicActivityDataItem> original;

  TemplateActivityWizardCubit({
    required this.editActivityCubit,
    required this.sortableBloc,
    required this.original,
  }) : super(WizardState(0, UnmodifiableListView([WizardStep.advance])));

  @override
  void next({bool warningConfirmed = false, SaveRecurring? saveRecurring}) {
    final editActivityState = editActivityCubit.state;
    if (!editActivityState.hasTitleOrImage) {
      return emit(state.failSave({SaveError.noTitleOrImage}));
    }
    final activity = editActivityState.activityToStore();
    final item = BasicActivityDataItem.fromActivity(activity);
    final sortable = original.copyWith(data: item);
    sortableBloc.add(SortableUpdated(sortable));

    emit(state.saveSuccess());
  }

  @override
  void removeCorrectedErrors() async {
    if (state.saveErrors.isNotEmpty &&
        editActivityCubit.state.hasTitleOrImage) {
      return emit(state.copyWith(saveErrors: {}));
    }
  }
}
