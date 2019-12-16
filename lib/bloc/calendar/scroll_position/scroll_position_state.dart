import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ScrollPositionState extends Equatable {
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
