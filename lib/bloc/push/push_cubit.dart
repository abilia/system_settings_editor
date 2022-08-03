import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';
import 'package:seagull/background/background.dart';
import 'package:seagull/bloc/all.dart';

part 'push_state.dart';

class PushCubit extends Cubit<PushState> {
  static final _log = Logger((PushCubit).toString());
  PushCubit() : super(PushReady()) {
    _initFirebaseListener();
  }

  void update([String? collapseKey]) => emit(PushReceived(collapseKey));

  void _initFirebaseListener() {
    // DO NOT REMOVE. The isAutoInitEnabled call is needed to make push work https://github.com/firebase/flutterfire/issues/6011
    FirebaseMessaging.instance.isAutoInitEnabled;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      update(message.collapseKey);
      _log.fine('onMessage push: ${message.collapseKey}');
    });
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }
}
