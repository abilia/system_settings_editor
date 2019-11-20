import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:seagull/bloc/push/push_bloc.dart';
import 'package:seagull/bloc/push/push_event.dart';

import '../bloc.dart';

class FirebasePush {
  PushBloc _pushBloc;

  Future<String> initPushToken() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    final token = await _firebaseMessaging.getToken();
    print('Got a token: $token');
    return token;
  }

  void initPushListeners(BuildContext context) {
    _pushBloc = BlocProvider.of<PushBloc>(context);
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    print('Init firebase push listeners');
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("got onMessage push: $message");
        _pushBloc.add(OnPush());
        print("onMessage push: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch push: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume push: $message");
      },
    );
  }
}
