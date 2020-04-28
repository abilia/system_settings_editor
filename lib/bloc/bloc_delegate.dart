import 'package:bloc/bloc.dart';
import 'all.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    if (event is! Silent) {
      log(event);
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (transition.event is! Silent) {
      log(transition);
    }
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    log(error);
  }
}

log(Object o) => print('${DateTime.now()}: $o');
