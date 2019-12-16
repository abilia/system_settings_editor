import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/mixin/silent.dart';

@immutable
abstract class ScrollPositionEvent extends Equatable {}

class ScrollPositionUpdated extends ScrollPositionEvent with Silent {
  final double scrollPosition;
  ScrollPositionUpdated(this.scrollPosition);
  @override
  List<Object> get props => [scrollPosition];
}

class ListViewRenderComplete extends ScrollPositionEvent {
  @override
  List<Object> get props => [];
}
