part of 'scroll_position_bloc.dart';

abstract class ScrollPositionState extends Equatable with Finest {
  @override
  List<Object> get props => [];
}

class Unready extends ScrollPositionState {}

class WrongDay extends ScrollPositionState {}

abstract class ScrollPositionReadyState extends ScrollPositionState {
  @override
  List<Object> get props => [scrollController];
  final ScrollController scrollController;

  ScrollPositionReadyState(this.scrollController);
}

class InView extends ScrollPositionReadyState {
  InView(ScrollController scrollController) : super(scrollController);
}

class OutOfView extends ScrollPositionReadyState {
  OutOfView(ScrollController scrollController) : super(scrollController);
}
