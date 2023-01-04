import 'package:memoplanner/bloc/all.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(Initial());

  void push() {
    emit(Push());
  }

  void replace() {
    emit(Replace());
  }

  void pop() {
    emit(Pop());
  }
}

abstract class NavigationState {}

class Initial extends NavigationState {}

class Push extends NavigationState {}

class Replace extends NavigationState {}

class Pop extends NavigationState {}
