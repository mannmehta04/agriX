// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      return web;
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
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyATYszSXiby_M7jZ5hWBa9itvzmkU9wsHs',
    appId: '1:969389328654:web:58e2a7d93333f991342f5f',
    messagingSenderId: '969389328654',
    projectId: 'agrix-65b7e',
    authDomain: 'agrix-65b7e.firebaseapp.com',
    storageBucket: 'agrix-65b7e.appspot.com',
    measurementId: 'G-BPKZ2YJ9X9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmfQVPj6zo4Fw2OSaD1Vu9fFW8nRU_hPE',
    appId: '1:969389328654:android:8b84d657f379be73342f5f',
    messagingSenderId: '969389328654',
    projectId: 'agrix-65b7e',
    storageBucket: 'agrix-65b7e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCW4HlmX4B4WTBW4MJYdGyF1XONIrEPy9s',
    appId: '1:969389328654:ios:aafdc132066d276b342f5f',
    messagingSenderId: '969389328654',
    projectId: 'agrix-65b7e',
    storageBucket: 'agrix-65b7e.appspot.com',
    iosBundleId: 'com.example.agrix',
  );
}