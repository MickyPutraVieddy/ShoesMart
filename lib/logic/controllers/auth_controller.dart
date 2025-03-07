import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_mart/logic/controllers/cart_controller.dart';

import '../../models/facebook_model.dart';
import '../../routes/routes.dart';

class AuthController extends GetxController {
  bool isVisibility = false;
  bool isCheckedBox = false;
  var displayUserName = ''.obs;
  var displayUserPhoto = ''.obs;
  var displayUserEmail = ''.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  var googleSignIn = GoogleSignIn();
  FaceBookModel? facebookModel;

  var isSignIn = false;
  final GetStorage authBox = GetStorage();

  User? get userProfile => auth.currentUser;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String capitalize(String profileName) {
    return profileName.split(' ').map((name) => name.capitalize).join(' ');
  }

  @override
  void onInit() {
    displayUserName.value =
        (userProfile != null ? userProfile!.displayName : '') ?? '';
    displayUserPhoto.value =
        (userProfile != null ? userProfile!.photoURL : '') ?? '';
    displayUserEmail.value = (userProfile != null ? userProfile!.email : '')!;

    super.onInit();
  }

  void visibility() {
    isVisibility = !isVisibility;
    update();
  }

  void checkBox() {
    isCheckedBox = !isCheckedBox;
    update();
  }

  Future<void> _storeUserRegisterData(String name, String email) async {
    try {
      await _firestore.collection('register').doc(auth.currentUser!.uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });
      print('User data stored in register collection successfully!');
    } catch (error) {
      print('Error storing user data in register collection: $error');
    }
  }

  void signUpUsingFirebase({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) {
        displayUserName.value = name;
        auth.currentUser!.updateDisplayName(name);

        // Store user data in Firestore upon successful signup
        _storeUserData(name, email);

        // Store user data in 'register' collection upon successful signup
        _storeUserRegisterData(name, email);
      });
      update();
      Get.offNamed(Routes.loginScreen);
    } on FirebaseAuthException catch (error) {
      String title = error.code.replaceAll(RegExp('-'), ' ').capitalize!;
      String message = '';
      if (error.code == 'weak-password') {
        message = 'Provided password is too weak..';
      } else if (error.code == 'email-already-in-use') {
        message = 'Account already exists for that email..';
      } else {
        message = error.message.toString();
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        'Error!',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void bypassLogin() {
    displayUserName.value = "Test User";
    displayUserEmail.value = "testuser@example.com";
    displayUserPhoto.value = ""; // Add a test photo URL if needed
    isSignIn = true;
    authBox.write('auth', isSignIn);
    update();
    Get.offNamed(Routes.mainScreen);
  }

  void logInUsingFirebase({
    required String email,
    required String password,
  }) async {
    try {
      await auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        displayUserName.value = auth.currentUser!.displayName!;
      });
      isSignIn = true;
      authBox.write('auth', isSignIn);

      // Retrieve and display user data from Firestore upon login
      _retrieveUserData(email);

      // Fetch cart data after user login
      Get.find<CartController>().fetchCartFromFirestore();

      update();
      Get.offNamed(Routes.mainScreen);
    } on FirebaseAuthException catch (error) {
      String title = error.code.replaceAll(RegExp('-'), ' ').capitalize!;
      String message = '';
      if (error.code == 'user-not-found') {
        message =
            'Account does not exist for that $email...Create your account by signing up';
      } else if (error.code == 'wrong-password') {
        message = 'Invalid Password...Please try again';
      } else {
        message = error.message.toString();
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        'Error!',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void googleSignUpApp() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      displayUserName.value = googleUser!.displayName!;
      displayUserPhoto.value = googleUser.photoUrl!;
      displayUserEmail.value = googleUser.email;

      GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      await auth.signInWithCredential(credential);

      isSignIn = true;
      authBox.write('auth', isSignIn);

      // Store user data in Firestore upon successful Google signup
      _storeUserData(googleUser.displayName!, googleUser.email);

      // Fetch cart data after user login
      Get.find<CartController>().fetchCartFromFirestore();

      update();
      Get.offNamed(Routes.mainScreen);
    } catch (error) {
      Get.snackbar(
        'Error!',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      debugPrint(error.toString());
    }
  }

  // Store user data in Firestore
  Future<void> _storeUserData(String name, String email) async {
    try {
      await _firestore.collection('login').doc(auth.currentUser!.uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });
    } catch (error) {
      print('Error storing user data: $error');
    }
  }

  // Retrieve user data from Firestore
  Future<void> _retrieveUserData(String email) async {
    try {
      var userData = await _firestore
          .collection('login')
          .where('email', isEqualTo: email)
          .get();

      if (userData.docs.isNotEmpty) {
        var user = userData.docs.first;
        print('User Data Retrieved: ${user.data()}');
        // Example: Update displayUserName with retrieved name
        displayUserName.value = user['name'];
        // Update other user information as needed
      } else {
        print('No user data found for email: $email');
      }
    } catch (error) {
      print('Error retrieving user data: $error');
    }
  }

  void resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      update();
      Get.back();
    } on FirebaseAuthException catch (error) {
      String title = error.code.replaceAll(RegExp('-'), ' ').capitalize!;
      String message = '';
      if (error.code == 'user-not-found') {
        message =
            'Account does not exist for that $email...Create your account by signing up';
      } else {
        message = error.message.toString();
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (error) {
      Get.snackbar(
        'Error!',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void signOutFromApp() async {
    try {
      await auth.signOut();
      await googleSignIn.signOut();
      //await FacebookAuth.instance.logOut();
      displayUserName.value = '';
      displayUserPhoto.value = '';
      displayUserEmail.value = '';
      isSignIn = false;
      authBox.remove('auth');
      update();
      Get.offNamed(Routes.welcomeScreen);
    } catch (error) {
      Get.snackbar(
        'Error!',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      debugPrint(error.toString());
    }
  }
}
