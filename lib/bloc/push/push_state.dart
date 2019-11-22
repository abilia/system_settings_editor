abstract class PushState {
  const PushState();
}

class PushUninitialized extends PushState {}

class PushReady extends PushState {}

class PushReceived extends PushState {}
