import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';

class ScrollPositionBloc
    extends Bloc<ScrollPositionEvent, ScrollPositionState> {
  final double fromTop;
  final double fromBotton;

  ScrollPositionBloc({this.fromTop = 8, this.fromBotton = 8});

  @override
  ScrollPositionState get initialState => Unready();

  @override
  Stream<ScrollPositionState> mapEventToState(
    ScrollPositionEvent event,
  ) async* {
    final s = state;
    if (event is WrongDaySelected) {
      yield WrongDay();
    } else if (event is ListViewRenderComplete) {
      yield* _isActivityInView(event.scrollController);
    } else if (event is ScrollPositionUpdated &&
        s is ScrollPositionReadyState) {
      yield* _isActivityInView(s.scrollController);
    }
  }

  Stream<ScrollPositionState> _isActivityInView(
      ScrollController scrollController) async* {
    if (!scrollController.hasClients) {
      yield Unready();
      return;
    }
    final scrollPosition = scrollController.offset;
    final maxScrollExtent = scrollController.position.maxScrollExtent;
    final offsetToActivity = scrollController.initialScrollOffset;
    if (_atBottomOfList(
        scrollPosition: scrollPosition,
        maxScrollExtent: maxScrollExtent,
        offsetToActivity: offsetToActivity)) {
      yield InView(scrollController);
    } else if (_inView(
        scrollPosition: scrollPosition, offsetToActivity: offsetToActivity)) {
      yield InView(scrollController);
    } else {
      yield OutOfView(scrollController);
    }
  }

  bool _atBottomOfList({
    @required double scrollPosition,
    @required double maxScrollExtent,
    @required double offsetToActivity,
  }) =>
      scrollPosition >= maxScrollExtent && offsetToActivity > maxScrollExtent;

  bool _inView({
    @required double scrollPosition,
    @required double offsetToActivity,
  }) =>
      offsetToActivity - scrollPosition <= fromBotton &&
      scrollPosition - offsetToActivity <= fromTop;
}
