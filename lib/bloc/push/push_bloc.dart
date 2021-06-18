// @dart=2.9

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';
import 'package:seagull/background/background.dart';
import 'package:seagull/bloc/all.dart';

part 'push_event.dart';
part 'push_state.dart';

class PushBloc extends Bloc<PushEvent, PushState> {
  static final _log = Logger((PushBloc).toString());
  PushBloc() : super(PushReady()) {
    _initFirebaseListener();
  }

  @override
  Stream<PushState> mapEventToState(event) async* {
    yield PushReceived(event.collapseKey);
  }

  void _initFirebaseListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      add(PushEvent(message.collapseKey));
      _log.fine('onMessage push: ${message.collapseKey}');
    });
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }
}
