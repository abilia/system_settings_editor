part of 'scroll_position_bloc.dart';

abstract class ScrollPositionEvent extends Equatable with Silent {
  const ScrollPositionEvent();
  @override
  bool get stringify => true;
  @override
  List<Object?> get props => [];
}

class WrongDaySelected extends ScrollPositionEvent {
  const WrongDaySelected();
}

class ScrollPositionUpdated extends ScrollPositionEvent {
  const ScrollPositionUpdated();
}

class ScrollViewRenderComplete extends ScrollPositionEvent {
  final ScrollController scrollController;
  final DateTime? createdTime;

  const ScrollViewRenderComplete(this.scrollController, {this.createdTime});
  @override
  List<Object?> get props => [scrollController, createdTime];
}

class GoToNow extends ScrollPositionEvent {
  const GoToNow();
}
