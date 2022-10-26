part of 'scroll_position_cubit.dart';

abstract class ScrollPositionState extends Equatable with Finest {
  @override
  List<Object?> get props => [];
}

class Unready extends ScrollPositionState {}

class WrongDay extends ScrollPositionState {}

abstract class ScrollPositionReadyState extends ScrollPositionState {
  final ScrollController scrollController;
  final double nowOffset, inViewMargin;
  ScrollPositionReadyState(
    this.scrollController,
    this.nowOffset,
    this.inViewMargin,
  );
  @override
  List<Object?> get props => [
        scrollController,
        nowOffset,
        inViewMargin,
      ];
}

class InView extends ScrollPositionReadyState {
  InView(
    ScrollController scrollController,
    double nowOffset,
    double inViewMargin,
  ) : super(
          scrollController,
          nowOffset,
          inViewMargin,
        );
}

class OutOfView extends ScrollPositionReadyState {
  OutOfView(
    ScrollController scrollController,
    double nowOffset,
    double inViewMargin,
  ) : super(
          scrollController,
          nowOffset,
          inViewMargin,
        );
}
