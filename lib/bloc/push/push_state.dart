import 'package:meta/meta.dart';

@immutable
abstract class PushState {
  const PushState();
}

class PushReady extends PushState {}

class PushReceived extends PushState {
  final String pushType;

  PushReceived(this.pushType);

  @override
  String toString() => 'PushReceived { pushType: $pushType }';
}

class PushType {
  static final String calendar = 'calendar', sortable = 'dataItem';
}
