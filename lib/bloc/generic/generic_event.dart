part of 'generic_bloc.dart';

abstract class GenericEvent {
  const GenericEvent();
}

class LoadGenerics extends GenericEvent {
  @override
  String toString() => 'LoadGenerics';
}

class GenericUpdated<T extends GenericData> extends GenericEvent {
  final T genericData;

  GenericUpdated(this.genericData);
}
