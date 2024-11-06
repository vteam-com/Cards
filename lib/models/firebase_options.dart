// firebase_options.example.dart
// Replace with your Firebase configuration
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_API_KEY',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
      authDomain: 'vteam-cards.firebaseapp.com',
      databaseURL: 'https://<YOUR PATH>.firebasedatabase.app',
      storageBucket: '<your project>.firebasestorage.app',
      measurementId: 'G-EXAMPLE',
    );
  }
}
