extension ThowsafeMap<E> on Iterable<E> {
  Iterable<T?> exceptionSafeMap<T>(
    T Function(E) function, {
    required Null Function(Object, StackTrace, E, T Function(E)) onException,
  }) =>
      map(
        (element) {
          try {
            return function(element);
          } catch (exception, stacktrace) {
            return onException(exception, stacktrace, element, function);
          }
        },
      );
}
