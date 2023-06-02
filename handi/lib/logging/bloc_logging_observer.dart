import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull_logging/logging.dart';
import 'package:seagull_logging/logging_levels_mixin.dart';

class BlocLoggingObserver extends BlocObserver {
  BlocLoggingObserver();

  final _loggers = <BlocBase, Logger>{};

  Logger _getLog(BlocBase bloc) =>
      _loggers[bloc] ??= Logger(bloc.runtimeType.toString());

  void _log(BlocBase bloc, Object? message) {
    if (bloc is Silent) return;
    final log = _getLog(bloc);
    if (bloc is Shout) {
      log.shout(message);
    } else if (bloc is Warning) {
      log.warning(message);
    } else if (bloc is Info) {
      log.info(message);
    } else if (bloc is Fine) {
      log.fine(message);
    } else if (bloc is Finest) {
      log.finest(message);
    } else {
      log.finer(message);
    }
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (bloc is Silent) return;
    _log(bloc, 'created ${bloc.state}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (event is Silent || bloc is Silent) return;
    _log(bloc, 'event $event');
  }

  @override
  Future<void> onChange(BlocBase bloc, Change change) async {
    super.onChange(bloc, change);
    if (bloc is Silent) return;
    _log(bloc, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (bloc is Silent) return;
    _log(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _getLog(bloc).severe(error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (bloc is Silent) return;
    _log(bloc, 'closed');
  }
}
