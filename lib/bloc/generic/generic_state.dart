part of 'generic_bloc.dart';

abstract class GenericState extends Equatable {
  const GenericState();
  @override
  bool get stringify => true;
}

class GenericsNotLoaded extends GenericState {
  @override
  List<Object> get props => [];
}

class GenericsLoaded extends GenericState {
  final MapView<String, Generic> generics;

  GenericsLoaded({
    required Map<String, Generic> generics,
  }) : generics = MapView(generics);

  @override
  List<Object> get props => [generics];
}

class GenericsLoadedFailed extends GenericState {
  @override
  List<Object> get props => [];
}
