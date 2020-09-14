part of 'generic_bloc.dart';

abstract class GenericEvent {
  const GenericEvent();
}

class LoadGenerics extends GenericEvent {
  @override
  String toString() => 'LoadGenerics';
}
