import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'recurring_week_state.dart';

class RecurringWeekCubit extends Cubit<RecurringWeekState> {
  late final StreamSubscription _editActivityCubitSubscription,
      _selfSubscription;

  RecurringWeekCubit(EditActivityCubit editActivityCubit)
      : super(RecurringWeekState.initial(editActivityCubit.state)) {
    _editActivityCubitSubscription =
        editActivityCubit.stream.listen((editActivityState) {
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
      editActivityCubit.changeWeeklyRecurring(recurringWeekState.recurs);
    });
  }

  void changeEveryOtherWeek(bool everyOtherWeek) =>
      emit(state.copyWith(everyOtherWeek: everyOtherWeek));

  void addOrRemoveWeekday(int day) {
    final weekdays = state.weekdays.toSet();
    if (!weekdays.remove(day)) {
      weekdays.add(day);
    }
    emit(state.copyWith(weekdays: weekdays));
  }

  void selectWeekdays([Set<int> days = const {}]) =>
      emit(state.copyWith(weekdays: days));

  @override
  Future<void> close() async {
    await _editActivityCubitSubscription.cancel();
    await _selfSubscription.cancel();
    return super.close();
  }
}
