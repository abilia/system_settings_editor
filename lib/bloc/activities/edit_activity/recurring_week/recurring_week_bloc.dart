import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'recurring_week_event.dart';
part 'recurring_week_state.dart';

class RecurringWeekBloc extends Bloc<RecurringWeekEvent, RecurringWeekState> {
  late final StreamSubscription _editActivityCubitSubscription,
      _selfSubscription;

  RecurringWeekBloc(EditActivityCubit editActivityCubit)
      : super(RecurringWeekState.initial(editActivityCubit.state)) {
    _editActivityCubitSubscription =
        editActivityCubit.stream.listen((editActivityState) {
      final startDate = editActivityState.timeInterval.startDate;
      final endDate = editActivityState.activity.recurs.end;
      if (editActivityState.activity.recurs.weekly) {
        if (startDate != state.startDate) {
          add(ChangeStartDate(startDate));
        }
        if (endDate != state.endDate) {
          add(ChangeEndDate(endDate));
        }
      }
    });

    _selfSubscription = stream.listen((recurringWeekState) {
      editActivityCubit.replaceActivity(
        editActivityCubit.state.activity.copyWith(
          recurs: recurringWeekState.recurs,
        ),
      );
    });
  }

  @override
  Stream<RecurringWeekState> mapEventToState(
    RecurringWeekEvent event,
  ) async* {
    if (event is ChangeEveryOtherWeek) {
      yield state.copyWith(everyOtherWeek: event.everyOtherWeek);
    }
    if (event is ChangeStartDate) {
      yield state.copyWith(startDate: event.startDate);
    }
    if (event is ChangeEndDate) {
      yield state.copyWith(endDate: event.endDate);
    }
    if (event is AddOrRemoveWeekday) {
      final weekdays = state.weekdays.toSet();
      if (!weekdays.remove(event.day)) {
        weekdays.add(event.day);
      }
      yield state.copyWith(weekdays: weekdays);
    }
    if (event is SelectWeekdays) {
      yield state.copyWith(weekdays: event.days);
    }
  }

  @override
  Future<void> close() async {
    await _editActivityCubitSubscription.cancel();
    await _selfSubscription.cancel();
    return super.close();
  }
}
