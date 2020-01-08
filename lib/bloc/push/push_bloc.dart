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
    yield PushReceived();
  }

  void _initFirebaseListener() {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        this.add(OnPush());
        print("onMessage push: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        this.add(OnPush());
        print("onLaunch push: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        this.add(OnPush());
        print("onResume push: $message");
      },
      onBackgroundMessage: myBackgroundMessageHandler,
    );
  }
}
