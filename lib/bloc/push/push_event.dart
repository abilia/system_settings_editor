import 'package:equatable/equatable.dart';

abstract class PushEvent extends Equatable {
  const PushEvent();
  @override
  List<Object> get props => null;
}

class OnPush extends PushEvent {}
