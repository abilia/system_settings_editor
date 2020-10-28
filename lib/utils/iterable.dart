import 'package:seagull/logging.dart';

extension ThowsafeMap<E> on Iterable<E> {
  Iterable exceptionSafeMap<T>(T Function(E e) function, {Logger log}) =>
      map((t) {
        try {
          return function(t);
        } catch (e) {
          log?.severe('Corrupt data, could not apply $function to $t', e);
          return null;
        }
      }).where((element) => element != null);
}
