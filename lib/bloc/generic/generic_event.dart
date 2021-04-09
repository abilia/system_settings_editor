part of 'generic_bloc.dart';

abstract class GenericEvent extends Equatable {
  const GenericEvent();
}

class LoadGenerics extends GenericEvent {
  @override
  List<Object> get props => [];
  @override
  String toString() => 'LoadGenerics';
}

class GenericUpdated extends GenericEvent {
  final Iterable<GenericData> genericData;

  GenericUpdated(this.genericData);
  @override
  List<Object> get props => [genericData];
  @override
  bool get stringify => true;
}
