import 'package:cards/firebase_options_private.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

bool backendReady = false;

Future<void> useFirebase() async {
  try {
    if (backendReady == false) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseAuth.instance.signInAnonymously();
      backendReady = true;
    }
  } catch (e) {
    backendReady = false;
    print('---------------------');
    print(e);
    print('---------------------');
  }
}
