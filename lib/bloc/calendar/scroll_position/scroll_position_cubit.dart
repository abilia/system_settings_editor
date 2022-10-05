import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/utils/all.dart';

part 'scroll_position_state.dart';

class ScrollPositionCubit extends Cubit<ScrollPositionState> {
  final double nowMarginTop;
  final double nowMarginBottom;

  final DayPickerBloc dayPickerBloc;
  final ClockBloc clockBloc;
  final TimepillarMeasuresCubit timepillarMeasuresCubit;
  late final StreamSubscription dayPickerBlocSubscription;
  late final StreamSubscription clockBlocSubscription;

  ScrollPositionCubit({
    required this.dayPickerBloc,
    required this.clockBloc,
    required this.timepillarMeasuresCubit,
    this.nowMarginTop = 8,
    this.nowMarginBottom = 8,
  }) : super(dayPickerBloc.state.isToday ? Unready() : WrongDay()) {
    dayPickerBlocSubscription = dayPickerBloc.stream
        .where((state) => !state.isToday)
        .listen((_) => wrongDaySelected());
    clockBlocSubscription =
        clockBloc.stream.listen((now) => scrollPositionUpdated());
  }

  Future<void> goToNow() async {
    final s = state;
    await _jumpToActivity(s);
    if (s is OutOfView) {
      emit(
        _isActivityInView(
          s.scrollController,
          s.scrollControllerCreatedTime,
        ),
      );
    } else if (s is InView) {
      emit(InView(
        s.scrollController,
        s.scrollControllerCreatedTime,
      ));
    } else {
      emit(Unready());
    }
  }

  bool wrongDaySelected() {
    if (!dayPickerBloc.state.isToday) {
      emit(WrongDay());
      return true;
    }
    return false;
  }

  void scrollViewRenderComplete(
    ScrollController scrollController, {
    DateTime? createdTime,
  }) {
    if (!wrongDaySelected()) {
      emit(
        _isActivityInView(
          scrollController,
          createdTime,
        ),
      );
    }
  }

  void scrollPositionUpdated() {
    final s = state;
    if (!wrongDaySelected() && s is ScrollPositionReadyState) {
      emit(
        _isActivityInView(
          s.scrollController,
          s.scrollControllerCreatedTime,
        ),
      );
    }
  }

  ScrollPositionState _isActivityInView(ScrollController scrollController,
      DateTime? scrollControllerCreatedTime) {
    if (!scrollController.hasClients) {
      return Unready();
    }
    final scrollPosition = scrollController.offset;
    final maxScrollExtent = scrollController.position.maxScrollExtent;
    final nowPosition = scrollController.initialScrollOffset +
        timeFromCreation(scrollControllerCreatedTime);

    if (_atBottomOfList(
      scrollPosition: scrollPosition,
      maxScrollExtent: maxScrollExtent,
      nowPosition: nowPosition,
    )) {
      return InView(
        scrollController,
        scrollControllerCreatedTime,
      );
    } else if (_inView(
      scrollPosition: scrollPosition,
      nowPosition: nowPosition,
    )) {
      return InView(
        scrollController,
        scrollControllerCreatedTime,
      );
    } else {
      return OutOfView(
        scrollController,
        scrollControllerCreatedTime,
      );
    }
  }

  bool _atBottomOfList({
    required double scrollPosition,
    required double maxScrollExtent,
    required double nowPosition,
  }) =>
      scrollPosition >= maxScrollExtent && nowPosition > maxScrollExtent;

  bool _inView({
    required double scrollPosition,
    required double nowPosition,
  }) =>
      nowPosition - scrollPosition <= nowMarginBottom &&
      scrollPosition - nowPosition <= nowMarginTop;

  double timeFromCreation(DateTime? scrollControllerCreatedTime) {
    if (scrollControllerCreatedTime != null) {
      final now = clockBloc.state;
      final diff = now.difference(scrollControllerCreatedTime);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % Duration.minutesPerHour;

      return timeToPixels(
          hours, minutes, timepillarMeasuresCubit.state.dotDistance);
    }
    return 0.0;
  }

  Future _jumpToActivity(ScrollPositionState state) async {
    if (state is ScrollPositionReadyState) {
      final sc = state.scrollController;
      final nowPos = sc.initialScrollOffset +
          timeFromCreation(state.scrollControllerCreatedTime);

      final offset = min(nowPos, sc.position.maxScrollExtent);
      await sc.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (state is WrongDay) {
      dayPickerBloc.add(const CurrentDay());
    }
  }

  @override
  Future<void> close() async {
    await dayPickerBlocSubscription.cancel();
    await clockBlocSubscription.cancel();
    return super.close();
  }
}
