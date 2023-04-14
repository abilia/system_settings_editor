part of 'scroll_position_cubit.dart';

abstract class ScrollPositionState extends Equatable with Finest {
  @override
  List<Object?> get props => [];
}

class ScrollPositionUnready extends ScrollPositionState {}

class WrongDay extends ScrollPositionState {}

class ScrollPositionReady extends ScrollPositionState {
  final ScrollController scrollController;
  final double nowOffset;
  ScrollPositionReady(
    this.scrollController,
    this.nowOffset,
  );
  @override
  List<Object?> get props => [
        scrollController,
        nowOffset,
      ];
}
