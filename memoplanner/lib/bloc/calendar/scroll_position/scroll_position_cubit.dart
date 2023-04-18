import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/ui/components/calendar/day_calendar.dart';

part 'scroll_position_state.dart';

class ScrollPositionCubit extends Cubit<ScrollPositionState> {
  final DayPickerBloc dayPickerBloc;
  late final StreamSubscription dayPickerBlocSubscription;

  ScrollPositionCubit({
    required this.dayPickerBloc,
  }) : super(dayPickerBloc.state.isToday
            ? ScrollPositionUnready()
            : WrongDay()) {
    dayPickerBlocSubscription = dayPickerBloc.stream
        .where((day) => !day.isToday)
        .listen((_) => emit(WrongDay()));
  }

  Future<void> goToNow({
    Duration duration = DayCalendarTab.transitionDuration,
    Curve curve = Curves.easeInOut,
  }) async {
    final scrollState = state;

    if (scrollState is WrongDay) {
      dayPickerBloc.add(const CurrentDay());
      return reset();
    }

    if (scrollState is ScrollPositionReady) {
      final sc = scrollState.scrollController;

      if (!sc.hasClients) return;

      final scrollTo = scrollState.nowOffset.clamp(
        sc.position.minScrollExtent,
        sc.position.maxScrollExtent,
      );

      if (scrollTo == scrollState.scrollController.offset) {
        return;
      }

      if (duration == Duration.zero) {
        return sc.jumpTo(scrollTo);
      }

      await sc.animateTo(
        scrollTo,
        duration: duration,
        curve: curve,
      );
    }
  }

  void updateNowOffset({required double nowOffset}) {
    final scrollState = state;
    if (scrollState is ScrollPositionReady) {
      emit(
        _getState(
          scrollState.scrollController,
          nowOffset,
        ),
      );
    }
  }

  void updateState({
    required ScrollController scrollController,
    required double nowOffset,
  }) {
    emit(
      _getState(
        scrollController,
        nowOffset,
      ),
    );
  }

  void reset() {
    emit(ScrollPositionUnready());
  }

  ScrollPositionState _getState(
    ScrollController sc,
    double nowOffset,
  ) {
    if (!dayPickerBloc.state.isToday) {
      return WrongDay();
    }

    if (sc.positions.length != 1) {
      return ScrollPositionUnready();
    }

    return ScrollPositionReady(sc, nowOffset);
  }

  @override
  Future<void> close() async {
    await dayPickerBlocSubscription.cancel();
    return super.close();
  }
}
