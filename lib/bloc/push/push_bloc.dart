import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';
import 'package:seagull/background/background.dart';
import 'package:seagull/bloc/all.dart';

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
    final firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        add(PushEvent(message['collapse_key']));
        _log.fine('onMessage push: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        add(PushEvent(message['collapse_key']));
        _log.fine('onLaunch push: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        add(PushEvent(message['collapse_key']));
        _log.fine('onResume push: $message');
      },
      onBackgroundMessage: myBackgroundMessageHandler,
    );
  }
}
