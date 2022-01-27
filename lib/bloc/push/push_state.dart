part of 'push_cubit.dart';

abstract class PushState {
  const PushState();
}

class PushReady extends PushState {}

class PushReceived extends PushState {
  final String? pushType;

  PushReceived(this.pushType);

  @override
  String toString() => 'PushReceived { pushType: $pushType }';
}

class PushType {
  static const String calendar = 'calendar', sortable = 'dataItem';
}
