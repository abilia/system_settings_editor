part of 'scroll_position_bloc.dart';

abstract class ScrollPositionState extends Equatable with Finest {
  @override
  List<Object?> get props => [];
}

class Unready extends ScrollPositionState {}

class WrongDay extends ScrollPositionState {}

abstract class ScrollPositionReadyState extends ScrollPositionState {
  final ScrollController scrollController;
  final DateTime? scrollControllerCreatedTime;
  ScrollPositionReadyState(
      this.scrollController, this.scrollControllerCreatedTime);
  @override
  List<Object?> get props => [scrollController, scrollControllerCreatedTime];
}

class InView extends ScrollPositionReadyState {
  InView(ScrollController scrollController,
      [DateTime? scrollControllerCreatedTime])
      : super(
          scrollController,
          scrollControllerCreatedTime,
        );
}

class OutOfView extends ScrollPositionReadyState {
  OutOfView(ScrollController scrollController,
      [DateTime? scrollControllerCreatedTime])
      : super(
          scrollController,
          scrollControllerCreatedTime,
        );
}
