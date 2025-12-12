import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBZKcHZH40hC766i8-NI8Qv1zAniSv_PSA',
    authDomain: 'utility-go.firebaseapp.com',
    projectId: 'utility-go',
    storageBucket: 'utility-go.firebasestorage.app',
    messagingSenderId: '270530921616',
    appId: '1:270530921616:web:1c61bcc837341de3e68415',
    measurementId: 'G-MRTBV64G0Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrysD_rA-GyQ6U_pb2EzwL6XaAgsQCLQM',
    appId: '1:270530921616:android:08c8bfb1de2bf1f6e68415',
    messagingSenderId: '270530921616',
    projectId: 'utility-go',
    storageBucket: 'utility-go.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAlgbLCMk3L0TB20i7CrzEe1NC-zb1iouI',
    appId: '1:270530921616:ios:9a6b4faf272f10fee68415',
    messagingSenderId: '270530921616',
    projectId: 'utility-go',
    storageBucket: 'utility-go.firebasestorage.app',
    iosBundleId: 'com.example.utilityGo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey-Replace-With-Your-Actual-Firebase-Key',
    appId: '1:123456789:macos:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    storageBucket: 'your-project.appspot.com',
    iosBundleId: 'com.example.utilityGo',
  );
}
