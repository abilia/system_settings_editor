import 'dart:collection';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class TemplateActivityWizardCubit extends WizardCubit {
  final EditActivityCubit editActivityCubit;
  final SortableBloc sortableBloc;
  final String? folderId;
  final Sortable<BasicActivityDataItem>? original;

  TemplateActivityWizardCubit({
    required this.editActivityCubit,
    required this.sortableBloc,
    this.folderId,
    this.original,
  })  : assert(folderId != null || original != null),
        super(WizardState(0, UnmodifiableListView([WizardStep.advance])));

  @override
  void next({bool warningConfirmed = false, SaveRecurring? saveRecurring}) {
    final editActivityState = editActivityCubit.state;
    if (!editActivityState.hasTitleOrImage) {
      return emit(state.failSave({SaveError.noTitleOrImage}));
    }
    final activity = editActivityState.activityToStore();
    final item = BasicActivityDataItem.fromActivity(activity);
    final sortable = original?.copyWith(data: item) ??
        Sortable.createNew(
          groupId: folderId ?? '',
          data: item,
        );

    sortableBloc.add(SortableUpdated(sortable));

    emit(state.saveSucess());
  }
}
