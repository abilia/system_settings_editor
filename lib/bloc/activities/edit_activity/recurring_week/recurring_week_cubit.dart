import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'recurring_week_state.dart';

class RecurringWeekCubit extends Cubit<RecurringWeekState> {
  late final StreamSubscription _editActivityBlocSubscription,
      _selfSubscription;

  RecurringWeekCubit(EditActivityBloc editActivityBloc)
      : super(RecurringWeekState.initial(editActivityBloc.state)) {
    _editActivityBlocSubscription =
        editActivityBloc.stream.listen((editActivityState) {
      final startDate = editActivityState.timeInterval.startDate;
      final endDate = editActivityState.activity.recurs.end;
      if (editActivityState.activity.recurs.weekly) {
        if (startDate != state.startDate) {
          emit(state.copyWith(startDate: startDate));
        }
        if (endDate != state.endDate) {
          emit(state.copyWith(endDate: endDate));
        }
      }
    });

    _selfSubscription = stream.listen((recurringWeekState) {
      editActivityBloc.add(
        ReplaceActivity(
          editActivityBloc.state.activity.copyWith(
            recurs: recurringWeekState.recurs,
          ),
        ),
      );
    });
  }

  void changeEveryOtherWeek(final bool everyOtherWeek) =>
      emit(state.copyWith(everyOtherWeek: everyOtherWeek));

  void addOrRemoveWeekday(final int day) {
    final weekdays = state.weekdays.toSet();
    if (!weekdays.remove(day)) {
      weekdays.add(day);
    }
    emit(state.copyWith(weekdays: weekdays));
  }

  selectWeekdays([final Set<int> days = const {}]) =>
      emit(state.copyWith(weekdays: days));

  @override
  Future<void> close() async {
    await _editActivityBlocSubscription.cancel();
    await _selfSubscription.cancel();
    return super.close();
  }
}
