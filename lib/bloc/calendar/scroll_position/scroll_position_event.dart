import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:seagull/logging.dart';

@immutable
abstract class ScrollPositionEvent extends Equatable with Silent {}

class WrongDaySelected extends ScrollPositionEvent {
  @override
  List<Object> get props => [];
}

class ScrollPositionUpdated extends ScrollPositionEvent {
  final double scrollPosition;
  ScrollPositionUpdated(this.scrollPosition);
  @override
  List<Object> get props => [scrollPosition];
  @override
  String toString() => 'ScrollPosition: $scrollPosition';
}

class ListViewRenderComplete extends ScrollPositionEvent {
  final ScrollController scrollController;

  ListViewRenderComplete(this.scrollController);
  @override
  List<Object> get props => [scrollController];
  @override
  String toString() => 'ListViewRenderComplete: { $scrollController }';
}
