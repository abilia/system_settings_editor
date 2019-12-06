import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/utils.dart';

class ScrollPositionBloc
    extends Bloc<ScrollPositionEvent, ScrollPositionState> {
  final ScrollController _scrollController;
  final ActivitiesOccasionBloc _activityOccasionBloc;
  final DayPickerBloc _dayPickerBloc;
  final ClockBloc _clockBloc;
  final GlobalKey<State> _currentActivityKey;
  final double _cardHeight;
  final viewPortFraction = 0.15;

  ScrollPositionBloc(
    this._activityOccasionBloc,
    this._clockBloc,
    this._dayPickerBloc,
    this._scrollController,
    this._cardHeight,
    this._currentActivityKey,
  );

  @override
  ScrollPositionState get initialState => Unready();

  @override
  Stream<ScrollPositionState> mapEventToState(
    ScrollPositionEvent event,
  ) async* {
    if (!_scrollController.hasClients ||
        _activityOccasionBloc.state is! ActivitiesOccasionLoaded) {
      yield Unready();
    } else if (!isAtSameDay(_dayPickerBloc.state, _clockBloc.state)) {
      yield WrongDay();
    } else {
      yield* _isActivityInView(
        scrollPosition: _scrollController.offset,
        maxScrollExtent: _scrollController.position.maxScrollExtent,
        offsetToActivity: _cardHeight *
            (_activityOccasionBloc.state as ActivitiesOccasionLoaded)
                .indexOfCurrentActivity,
      );
    }
  }

  Stream<ScrollPositionState> _isActivityInView({
    @required double scrollPosition,
    @required double maxScrollExtent,
    @required double offsetToActivity,
  }) async* {
    if (_emptyList(offsetToActivity)) {
      yield InView();
    } else if (_atBottomOfList(
        scrollPosition: scrollPosition,
        maxScrollExtent: maxScrollExtent,
        offsetToActivity: offsetToActivity)) {
      yield InView();
    } else if (_isRenderObjectOfKeyVisibleInViewPort(_currentActivityKey,
        scrollPosition: scrollPosition)) {
      yield InView();
    } else {
      yield OutOfView();
    }
  }

  bool _emptyList(offsetToActivity) => offsetToActivity < 0.0;
  bool _atBottomOfList({
    @required double scrollPosition,
    @required double maxScrollExtent,
    @required double offsetToActivity,
  }) =>
      scrollPosition >= maxScrollExtent && offsetToActivity > maxScrollExtent;

  bool _isRenderObjectOfKeyVisibleInViewPort(GlobalKey<State> currentActivityKey,
      {@required double scrollPosition}) {

    final RenderObject renderObject =
        currentActivityKey.currentContext?.findRenderObject();
    if (renderObject == null) return false;

    final viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) return false;

    final double offsetToRevealBottom =
        viewport.getOffsetToReveal(renderObject, viewPortFraction).offset;
    final double offsetToRevealTop =
        viewport.getOffsetToReveal(renderObject, 0.0).offset;
    return scrollPosition > offsetToRevealBottom &&
        scrollPosition < offsetToRevealTop;
  }
}
