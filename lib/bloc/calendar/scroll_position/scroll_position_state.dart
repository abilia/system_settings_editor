
import 'package:equatable/equatable.dart';

abstract class ScrollPositionState extends Equatable {
  @override
  List<Object> get props => [];
}

class Unready extends ScrollPositionState {}

class WrongDay extends ScrollPositionState {}

class InView extends ScrollPositionState {}

class OutOfView extends ScrollPositionState {}
