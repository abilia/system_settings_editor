export 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:seagull/background/background.dart';
import 'package:seagull/bloc/all.dart';

class PushCubit extends Cubit<RemoteMessage> {
  static final _log = Logger((PushCubit).toString());
  PushCubit() : super(const RemoteMessage()) {
    _initFirebaseListener();
  }

  @visibleForTesting
  void fakePush({
    Map<String, String> data = const {},
  }) =>
      emit(RemoteMessage(data: data));

  void _initFirebaseListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      emit(message);
      _log.fine('onMessage push: ${message.toMap()}');
    });
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }
}
