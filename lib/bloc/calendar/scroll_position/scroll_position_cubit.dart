import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';

part 'scroll_position_state.dart';

class ScrollPositionCubit extends Cubit<ScrollPositionState> {
  final DayPickerBloc dayPickerBloc;
  late final StreamSubscription dayPickerBlocSubscription;

  ScrollPositionCubit({
    required this.dayPickerBloc,
  }) : super(dayPickerBloc.state.isToday ? Unready() : WrongDay()) {
    dayPickerBlocSubscription = dayPickerBloc.stream
        .where((day) => !day.isToday)
        .listen((_) => emit(WrongDay()));
  }

  Future<void> goToNow({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    final scrollState = state;

    if (scrollState is WrongDay) {
      dayPickerBloc.add(const CurrentDay());
    }

    if (scrollState is ScrollPositionReadyState) {
      final sc = scrollState.scrollController;

      final scrollTo = scrollState.nowOffset.clamp(
        sc.position.minScrollExtent,
        sc.position.maxScrollExtent,
      );

      if (scrollTo == scrollState.scrollController.offset) {
        return;
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
    if (scrollState is ScrollPositionReadyState) {
      updateState(
        scrollController: scrollState.scrollController,
        nowOffset: nowOffset,
        inViewMargin: scrollState.inViewMargin,
      );
    }
  }

  void updateState({
    required ScrollController scrollController,
    required double nowOffset,
    required double inViewMargin,
  }) {
    emit(
      _getState(
        scrollController,
        nowOffset,
        inViewMargin,
      ),
    );
  }

  void reset() {
    emit(Unready());
  }

  void scrollPositionUpdated() {
    final scrollState = state;

    if (scrollState is ScrollPositionReadyState) {
      emit(
        _getState(
          scrollState.scrollController,
          scrollState.nowOffset,
          scrollState.inViewMargin,
        ),
      );
    }
  }

  ScrollPositionState _getState(
    ScrollController sc,
    double nowOffset,
    double inViewMargin,
  ) {
    if (!dayPickerBloc.state.isToday) {
      return WrongDay();
    }

    if (!(sc.positions.length == 1)) {
      return Unready();
    }

    final clampedNowOffset = nowOffset.clamp(
      sc.position.minScrollExtent,
      sc.position.maxScrollExtent,
    );

    final inViewBottomOffset = clampedNowOffset + inViewMargin;
    final inViewTopOffset = clampedNowOffset - inViewMargin;
    final currentOffset = sc.offset;

    final isInView =
        currentOffset <= inViewBottomOffset && currentOffset >= inViewTopOffset;

    return isInView
        ? InView(
            sc,
            nowOffset,
            inViewMargin,
          )
        : OutOfView(
            sc,
            nowOffset,
            inViewMargin,
          );
  }

  @override
  Future<void> close() async {
    await dayPickerBlocSubscription.cancel();
    return super.close();
  }
}
