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
    apiKey: 'AIzaSyDlRKfCYbGxyoA25sopK5QX9xyEtysPu8s',
    appId: '1:477439941618:web:361362e8f015e06650e96b',
    messagingSenderId: '477439941618',
    projectId: 'flutter1-7cb03',
    authDomain: 'flutter1-7cb03.firebaseapp.com',
    storageBucket: 'flutter1-7cb03.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCIBNDKyyBydoSOjlB5FYmRAhNu2wPUQ8',
    appId: '1:477439941618:android:3c2a0ba636518ce150e96b',
    messagingSenderId: '477439941618',
    projectId: 'flutter1-7cb03',
    storageBucket: 'flutter1-7cb03.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAN9ZRZ6syCXzV-2T4TglKHfyUeQuLFId8',
    appId: '1:477439941618:ios:ce22fb5da4d7634250e96b',
    messagingSenderId: '477439941618',
    projectId: 'flutter1-7cb03',
    storageBucket: 'flutter1-7cb03.firebasestorage.app',
    androidClientId: '477439941618-24lgjrv7odq84641f03knprf4kolqgas.apps.googleusercontent.com',
    iosClientId: '477439941618-gqhg5mfhd05a8dbvbohmob7c14rtue79.apps.googleusercontent.com',
    iosBundleId: 'com.example.students',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAN9ZRZ6syCXzV-2T4TglKHfyUeQuLFId8',
    appId: '1:477439941618:ios:ce22fb5da4d7634250e96b',
    messagingSenderId: '477439941618',
    projectId: 'flutter1-7cb03',
    storageBucket: 'flutter1-7cb03.firebasestorage.app',
    androidClientId: '477439941618-24lgjrv7odq84641f03knprf4kolqgas.apps.googleusercontent.com',
    iosClientId: '477439941618-gqhg5mfhd05a8dbvbohmob7c14rtue79.apps.googleusercontent.com',
    iosBundleId: 'com.example.students',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDlRKfCYbGxyoA25sopK5QX9xyEtysPu8s',
    appId: '1:477439941618:web:5fdd7f47c444afb350e96b',
    messagingSenderId: '477439941618',
    projectId: 'flutter1-7cb03',
    authDomain: 'flutter1-7cb03.firebaseapp.com',
    storageBucket: 'flutter1-7cb03.firebasestorage.app',
  );
}
