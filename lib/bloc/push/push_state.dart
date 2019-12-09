import 'package:meta/meta.dart';

@immutable
abstract class PushState {
  const PushState();
}

class PushReady extends PushState {}

class PushReceived extends PushState {}
