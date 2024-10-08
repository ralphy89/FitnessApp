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
    apiKey: 'AIzaSyCn2izRcvnw723ooD-daJX0IsNAJF7-UCM',
    appId: '1:454445262297:web:3626cfb191a723855ea5c8',
    messagingSenderId: '454445262297',
    projectId: 'fitness-app-0002',
    authDomain: 'fitness-app-0002.firebaseapp.com',
    storageBucket: 'fitness-app-0002.appspot.com',
    measurementId: 'G-PDRG0XB0YD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFfTzpcl7gr8V0bHBvCjtBMkwPMzzFxkM',
    appId: '1:454445262297:android:45607a5d89ce3aae5ea5c8',
    messagingSenderId: '454445262297',
    projectId: 'fitness-app-0002',
    storageBucket: 'fitness-app-0002.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDsHkQY_XoVfdhT8wDAIbyZbnn_L63J0dA',
    appId: '1:454445262297:ios:45bc8358e6cbd2a55ea5c8',
    messagingSenderId: '454445262297',
    projectId: 'fitness-app-0002',
    storageBucket: 'fitness-app-0002.appspot.com',
    iosClientId: '454445262297-btnmaa9abvmmfcrmeksn70cnni2abep2.apps.googleusercontent.com',
    iosBundleId: 'com.fitnessApp.fitnessApp',
  );

}