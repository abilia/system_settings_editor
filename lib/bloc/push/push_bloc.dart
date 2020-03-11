import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:seagull/background/background.dart';
import 'package:seagull/bloc/all.dart';

class PushBloc extends Bloc<PushEvent, PushState> {
  PushBloc() {
    _initFirebaseListener();
  }

  @override
  get initialState => PushReady();

  @override
  Stream<PushState> mapEventToState(event) async* {
    yield PushReceived(event.collapseKey);
  }

  void _initFirebaseListener() {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        this.add(PushEvent(message['collapse_key']));
        print("onMessage push: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        this.add(PushEvent(message['collapse_key']));
        print("onLaunch push: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        this.add(PushEvent(message['collapse_key']));
        print("onResume push: $message");
      },
      onBackgroundMessage: myBackgroundMessageHandler,
    );
  }
}
