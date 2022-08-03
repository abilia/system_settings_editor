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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      update(message.collapseKey);
      _log.fine('onMessage push: ${message.collapseKey}');
    });
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }
}
