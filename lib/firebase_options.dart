
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTp6nuzewpU2Rhyas8WXjWfeW4oDLgG7Q',
    appId: '1:309625865427:android:9f0be871c7dbd200a2c026',
    messagingSenderId: '309625865427',
    projectId: 'adhimeds-vendor-90454',
    storageBucket: 'adhimeds-vendor-90454.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQBKD5RFYlLU6uHjAm9h_ojFMNIkmQELk',
    appId: '1:309625865427:ios:e287c8a7ddc64c71a2c026',
    messagingSenderId: '309625865427',
    projectId: 'adhimeds-vendor-90454',
    storageBucket: 'adhimeds-vendor-90454.appspot.com',
    iosBundleId: 'com.adhimedsvendor.application',
  );
}
