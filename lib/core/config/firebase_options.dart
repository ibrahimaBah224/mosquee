import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuration Firebase pour toutes les plateformes
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCLB-F-sHmVZgTO4ukY8OplFkHMHMBO2ys',
    appId: '1:775213541089:web:00c26e4a5e7a23c3f579a0',
    messagingSenderId: '775213541089',
    projectId: 'mosquee-64c87',
    authDomain: 'mosquee-64c87.firebaseapp.com',
    storageBucket: 'mosquee-64c87.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLB-F-sHmVZgTO4ukY8OplFkHMHMBO2ys',
    appId: '1:775213541089:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: '775213541089',
    projectId: 'mosquee-64c87',
    storageBucket: 'mosquee-64c87.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLB-F-sHmVZgTO4ukY8OplFkHMHMBO2ys',
    appId: '1:775213541089:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '775213541089',
    projectId: 'mosquee-64c87',
    storageBucket: 'mosquee-64c87.firebasestorage.app',
    iosBundleId: 'com.example.mosquee',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCLB-F-sHmVZgTO4ukY8OplFkHMHMBO2ys',
    appId: '1:775213541089:ios:YOUR_MACOS_APP_ID',
    messagingSenderId: '775213541089',
    projectId: 'mosquee-64c87',
    storageBucket: 'mosquee-64c87.firebasestorage.app',
    iosBundleId: 'com.example.mosquee',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCLB-F-sHmVZgTO4ukY8OplFkHMHMBO2ys',
    appId: '1:775213541089:web:00c26e4a5e7a23c3f579a0',
    messagingSenderId: '775213541089',
    projectId: 'mosquee-64c87',
    authDomain: 'mosquee-64c87.firebaseapp.com',
    storageBucket: 'mosquee-64c87.firebasestorage.app',
  );
}
