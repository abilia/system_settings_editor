// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDL3FquIzdCRq22J56lYdhR-RUA-DtITHI',
    appId: '1:340774293730:android:1c4f68b6c0398038198ebb',
    messagingSenderId: '340774293730',
    projectId: 'whalewhale2013',
    databaseURL: 'https://whalewhale2013.firebaseio.com',
    storageBucket: 'whalewhale2013.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBhCZcbDzewnT2XpoiJELaYa9jT03LJn08',
    appId: '1:340774293730:ios:b746b675d6032844198ebb',
    messagingSenderId: '340774293730',
    projectId: 'whalewhale2013',
    databaseURL: 'https://whalewhale2013.firebaseio.com',
    storageBucket: 'whalewhale2013.appspot.com',
    androidClientId:
        '340774293730-2d5k7dr9cgl2re8chbk85ltjh05s2v6v.apps.googleusercontent.com',
    iosClientId:
        '340774293730-q6b73loqrdbc42aif27gacsd5ib4640q.apps.googleusercontent.com',
    iosBundleId: 'com.abilia.memoplannergo',
  );
}
