import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PushEvent extends Equatable {
  const PushEvent();
  @override
  List<Object> get props => [];
}

class OnPush extends PushEvent {}
