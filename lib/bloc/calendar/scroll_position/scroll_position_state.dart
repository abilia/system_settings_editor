import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ScrollPositionState extends Equatable {
  @override
  List<Object> get props => [];
}

class Unready extends ScrollPositionState {}

class WrongDay extends ScrollPositionState {}

class InView extends ScrollPositionState {}

class OutOfView extends ScrollPositionState {}
