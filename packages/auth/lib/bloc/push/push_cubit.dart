export 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

class PushCubit extends Cubit<RemoteMessage> {
  static final _log = Logger((PushCubit).toString());
  PushCubit({BackgroundMessageHandler? backgroundMessageHandler})
      : super(const RemoteMessage()) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      emit(message);
      _log.fine('onMessage push: ${message.toMap()}');
    });
    if (backgroundMessageHandler != null) {
      FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
    }
  }
  @visibleForTesting
  void fakePush({
    Map<String, String> data = const {},
  }) =>
      emit(RemoteMessage(data: data));
}
