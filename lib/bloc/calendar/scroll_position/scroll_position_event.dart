part of 'scroll_position_bloc.dart';

abstract class ScrollPositionEvent extends Equatable with Silent {
  @override
  bool get stringify => true;
}

class WrongDaySelected extends ScrollPositionEvent {
  @override
  List<Object> get props => [];
}

class ScrollPositionUpdated extends ScrollPositionEvent {
  final double scrollPosition;
  ScrollPositionUpdated(this.scrollPosition);
  @override
  List<Object> get props => [scrollPosition];
}

class ScrollViewRenderComplete extends ScrollPositionEvent {
  final ScrollController scrollController;

  ScrollViewRenderComplete(this.scrollController);
  @override
  List<Object> get props => [scrollController];
}
