import 'package:memoplanner/bloc/all.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const Initial(''));

  void push(String? routeName) {
    emit(Push(routeName));
  }

  void replace(String? routeName) {
    emit(Replace(routeName));
  }

  void pop(String? routeName) {
    emit(Pop(routeName));
  }
}

abstract class NavigationState {
  final String? currentRouteName;

  const NavigationState(this.currentRouteName);
}

class Initial extends NavigationState {
  const Initial(super.currentRouteName);
}

class Push extends NavigationState {
  const Push(super.currentRouteName);
}

class Replace extends NavigationState {
  const Replace(super.currentRouteName);
}

class Pop extends NavigationState {
  const Pop(super.currentRouteName);
}
