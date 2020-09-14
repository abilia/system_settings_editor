part of 'generic_bloc.dart';

abstract class GenericState extends Equatable {
  const GenericState();
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class GenericsNotLoaded extends GenericState {}

class GenericsLoaded extends GenericState {
  final List<Generic> generics;

  const GenericsLoaded({
    this.generics,
  });

  @override
  List<Object> get props => [generics];
}

class GenericsLoadedFailed extends GenericState {}
