import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  // For mobile, we use the provided clientId.
  // For web, clientId is not required.
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: !kIsWeb
        ? '268691332678-7nnnbpg69jf78ldeu4eahl9mku9280t0.apps.googleusercontent.com'
        : null,
  );

  // Google Sign-In method supporting both mobile and web
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web sign-in using FirebaseAuth's signInWithPopup
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        // Optionally add extra scopes if needed:
        // googleProvider.addScope('https://www.googleapis.com/auth/calendar.readonly');
        return await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // Mobile sign-in using the google_sign_in package
        final GoogleSignInAccount? gUser = await googleSignIn.signIn();
        if (gUser == null) return null; // User canceled the sign-in

        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        // Create a new credential using the obtained tokens
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        // Sign in with the credential
        return await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }
}
