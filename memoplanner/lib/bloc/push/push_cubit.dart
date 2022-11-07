export 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:memoplanner/background/background.dart';
import 'package:memoplanner/bloc/all.dart';

class PushCubit extends Cubit<RemoteMessage> {
  static final _log = Logger((PushCubit).toString());
  static const Map<String, String> fakeMessage = {'fake': 'message'};
  PushCubit() : super(const RemoteMessage()) {
    _initFirebaseListener();
  }

  @visibleForTesting
  void fakePush({
    Map<String, String> data = fakeMessage,
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
