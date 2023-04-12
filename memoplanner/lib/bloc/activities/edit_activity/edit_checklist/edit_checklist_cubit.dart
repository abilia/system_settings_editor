import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:rxdart/rxdart.dart';

part 'edit_checklist_state.dart';

class EditChecklistCubit extends Cubit<EditChecklistState> {
  final EditActivityCubit editActivityCubit;
  late final StreamSubscription _checklistStreamSubscription;

  EditChecklistCubit(this.editActivityCubit)
      : super(EditChecklistState(editActivityCubit.state.activity.infoItem)) {
    _checklistStreamSubscription = editActivityCubit.stream
        .map((state) => state.activity.infoItem)
        .whereType<Checklist>()
        .where((checklist) => checklist.questions != state.checklist.questions)
        .listen(changeChecklist);
  }

  void changeChecklist(Checklist checklist) {
    final i = checklist.questions.indexWhere((q) => q.id == state.selected?.id);
    emit(EditChecklistState(checklist, i >= 0 ? i : null));
  }

  void select(Question q) {
    final i = state.checklist.questions.indexOf(q);
    emit(EditChecklistState(state.checklist, i == state.index ? null : i));
  }

  void reorder(SortableReorderDirection direction) {
    final qIndex = state.index;
    if (qIndex != null) {
      final questions = state.checklist.questions.toList();
      final swapWithIndex =
          direction == SortableReorderDirection.up ? qIndex - 1 : qIndex + 1;

      if (qIndex >= 0 &&
          qIndex < questions.length &&
          swapWithIndex >= 0 &&
          swapWithIndex < questions.length) {
        final tmpQ = questions[qIndex];
        questions[qIndex] = questions[swapWithIndex];
        questions[swapWithIndex] = tmpQ;
      }

      editActivityCubit.replaceActivity(
        editActivityCubit.state.activity.copyWith(
          infoItem: state.checklist.copyWith(questions: questions),
        ),
      );
    }
  }

  void delete() {
    final deletedQuestion = state.selected;
    if (deletedQuestion != null) {
      final checklist = state.checklist;
      final filteredQuestions =
          state.checklist.questions.where((q) => q.id != deletedQuestion.id);
      editActivityCubit.replaceActivity(
        editActivityCubit.state.activity.copyWith(
          infoItem: checklist.copyWith(questions: filteredQuestions),
        ),
      );
    }
  }

  void edit(ImageAndName result) {
    final oldQuestion = state.selected;
    if (oldQuestion != null) {
      final checklist = state.checklist;
      final questionMap = {for (var q in checklist.questions) q.id: q};
      if (result.isEmpty) {
        questionMap.remove(oldQuestion.id);
      } else {
        questionMap[oldQuestion.id] = Question(
          id: oldQuestion.id,
          name: result.name,
          fileId: result.image.id,
          image: result.image.path,
        );
      }

      editActivityCubit.replaceActivity(
        editActivityCubit.state.activity.copyWith(
          infoItem: checklist.copyWith(questions: questionMap.values),
        ),
      );
    }
  }

  void newQuestion(ImageAndName result) {
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    editActivityCubit.replaceActivity(
      editActivityCubit.state.activity.copyWith(
        infoItem: state.checklist.copyWith(
          questions: [
            ...state.checklist.questions,
            Question(
              id: uniqueId,
              name: result.name,
              fileId: result.image.id,
              image: result.image.path,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _checklistStreamSubscription.cancel();
    return super.close();
  }
}
