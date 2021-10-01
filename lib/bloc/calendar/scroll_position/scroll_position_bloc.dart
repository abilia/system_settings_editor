import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/utils/all.dart';

part 'scroll_position_event.dart';
part 'scroll_position_state.dart';

class ScrollPositionBloc
    extends Bloc<ScrollPositionEvent, ScrollPositionState> {
  final double nowMarginTop;
  final double nowMarginBottom;

  final DayPickerBloc dayPickerBloc;
  final ClockBloc clockBloc;
  final TimepillarBloc timepillarBloc;
  late final StreamSubscription dayPickerBlocSubscription;
  late final StreamSubscription clockBlocSubscription;

  ScrollPositionBloc({
    required this.dayPickerBloc,
    required this.clockBloc,
    required this.timepillarBloc,
    this.nowMarginTop = 8,
    this.nowMarginBottom = 8,
  }) : super(dayPickerBloc.state.isToday ? Unready() : WrongDay()) {
    dayPickerBlocSubscription = dayPickerBloc.stream
        .where((state) => !state.isToday)
        .listen((_) => add(WrongDaySelected()));
    clockBlocSubscription =
        clockBloc.stream.listen((now) => add(ScrollPositionUpdated()));
  }

  @override
  Stream<ScrollPositionState> mapEventToState(
    ScrollPositionEvent event,
  ) async* {
    final s = state;
    if (event is GoToNow && s is OutOfView) {
      await _jumpToActivity(s);
      yield* _isActivityInView(
        s.scrollController,
        s.scrollControllerCreatedTime,
      );
    } else if (event is GoToNow) {
      await _jumpToActivity(s);
      yield Unready();
    } else if (!dayPickerBloc.state.isToday) {
      yield WrongDay();
    } else if (event is ScrollViewRenderComplete) {
      yield* _isActivityInView(
        event.scrollController,
        event.createdTime,
      );
    } else if (event is ScrollPositionUpdated &&
        s is ScrollPositionReadyState) {
      yield* _isActivityInView(
        s.scrollController,
        s.scrollControllerCreatedTime,
      );
    }
  }

  Stream<ScrollPositionState> _isActivityInView(
      ScrollController scrollController,
      DateTime? scrollControllerCreatedTime) async* {
    if (!scrollController.hasClients) {
      yield Unready();
      return;
    }
    final scrollPosition = scrollController.offset;
    final maxScrollExtent = scrollController.position.maxScrollExtent;
    var nowPosition = scrollController.initialScrollOffset +
        timeFromCreation(scrollControllerCreatedTime);

    if (_atBottomOfList(
      scrollPosition: scrollPosition,
      maxScrollExtent: maxScrollExtent,
      nowPosition: nowPosition,
    )) {
      yield InView(
        scrollController,
        scrollControllerCreatedTime,
      );
    } else if (_inView(
      scrollPosition: scrollPosition,
      nowPosition: nowPosition,
    )) {
      yield InView(
        scrollController,
        scrollControllerCreatedTime,
      );
    } else {
      yield OutOfView(
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

      return timeToPixels(hours, minutes, timepillarBloc.state.dotDistance);
    }
    return 0.0;
  }

  Future _jumpToActivity(ScrollPositionState state) async {
    if (state is OutOfView) {
      final sc = state.scrollController;
      var nowPos = sc.initialScrollOffset +
          timeFromCreation(state.scrollControllerCreatedTime);

      final offset = min(nowPos, sc.position.maxScrollExtent);
      await sc.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (state is WrongDay) {
      dayPickerBloc.add(CurrentDay());
    }
  }

  @override
  Future<void> close() async {
    await dayPickerBlocSubscription.cancel();
    await clockBlocSubscription.cancel();
    return super.close();
  }
}
