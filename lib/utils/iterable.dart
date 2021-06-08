extension ThowsafeMap<E> on Iterable<E> {
  Iterable<T> exceptionSafeMap<T>(
    T Function(E) function, {
    required T Function(dynamic, E) onException,
  }) =>
      map((e) {
        try {
          return function(e);
        } catch (exception) {
          return onException(exception, e);
        }
      });

  Iterable<E> filterNull() => where((element) => element != null);
}
