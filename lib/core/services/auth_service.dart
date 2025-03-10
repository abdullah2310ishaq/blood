import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Get the currently logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ✅ Register user with email & password and save data in Firestore
  Future<User?> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String contact,
    required String city,
    required String role,
  }) async {
    try {
      UserCredential result =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          contact: contact,
          role: role, // Role is now set directly.
          profilePic: "",
          city: city,
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }
      return user;
    } catch (e) {
      print("Error registering user: $e");
      rethrow;
    }
  }

  // ✅ Sign in with email & password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print("Error signing in with email: $e");
      rethrow;
    }
  }

  // ✅ Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User canceled sign-in.

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      // Check if Firestore document exists; if not, create it.
      DocumentSnapshot doc = await _firestore.collection('users').doc(user!.uid).get();
      if (!doc.exists) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          contact: '',
          role: "", // Role left empty to be set later.
          profilePic: user.photoURL,
          city: '',
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }
      return user;
    } catch (e) {
      print("Error signing in with Google: $e");
      rethrow;
    }
  }

  // ✅ Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ✅ Set the user's role (e.g., "donor" or "receiver") in Firestore
  Future<void> setUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({"role": role});
    } catch (e) {
      print("Error setting user role: $e");
      rethrow;
    }
  }

  // ✅ Get the user's role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.get("role") as String?;
      }
      return null;
    } catch (e) {
      print("Error getting user role: $e");
      return null;
    }
  }
}
