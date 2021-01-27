import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire/views/reg_profile.dart';
import 'package:flutterfire/views/dashboard.dart';
class Utils {

 static alert(BuildContext context, String message){
  showDialog(
   context: context,
   builder: (BuildContext context) {
    return AlertDialog(
     title: Text("Error"),
     content: Text(message),
     actions: <Widget>[
      FlatButton(
       child: Text("Close"),
       onPressed: () {
        Navigator.of(context).pop();
       },
      )
     ],
    );
   });
 }

 static String emailValidator(String value) {
  Pattern pattern =
   r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value)) {
   return 'Email is invalid';
  } else {
   return null;
  }
 }

 static String passwordValidator(String value) {
  if (value.length < 8) {
   return 'Password must be longer than 8 characters';
  } else {
   return null;
  }
 }

 static String addressValidator(String value) {
  if (value == null) {
   return 'Address must not be empty';
  } else {
   return null;
  }
 }

 static String nameValidator(String value) {
  if (value == null) {
   return 'Name must not be empty';
  } else {
   return null;
  }
 }

 static String phoneValidator(String value) {
  if (value.length < 10) {
   return 'Phone no. must not be empty';
  } else {
   return null;
  }
 }

 static Future<String> getCurrentUser() async {
  FirebaseUser user;
  String userID;
  user = await FirebaseAuth.instance.currentUser();
  userID = user.uid.toString();
  //print(userID);
  return userID;
 }

 static void loginUser(BuildContext context, GlobalKey<FormState> formKey,
  TextEditingController emailInputController,
  TextEditingController pwdInputController) async {
  if (formKey.currentState.validate()) {
   FirebaseAuth.instance.signInWithEmailAndPassword(
    email: emailInputController.text,
    password: pwdInputController.text)
    .then((currentUser) =>
    Firestore.instance
     .collection("users")
     .document(currentUser.user.uid)
     .get()
     .then((DocumentSnapshot result) =>
     Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => DashBoard()))
    )
     .catchError((err) => print(err)))
    .catchError((err) => alert(context, "Can't login, check your email or password."));
  }
 }

 static void registerCredentials(BuildContext context,
  GlobalKey<FormState> formKey,
  TextEditingController emailInputController,
  TextEditingController pwdInputController,
  TextEditingController confirmPwdInputController, bool task) async {
  if (formKey.currentState.validate()) {
   if (pwdInputController.text == confirmPwdInputController.text) {

    task = true;

    FirebaseAuth.instance.createUserWithEmailAndPassword(
     email: emailInputController.text,
     password: pwdInputController.text)
     .then((currentUser) =>
     Firestore.instance
      .collection("users")
      .document(currentUser.user.uid)
      .setData({
      "userID": currentUser.user.uid,
      "email": emailInputController.text,
      "profile_photo_url": "",
     })).whenComplete(() {
     Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => RegistrationProfile())
     );
    }).catchError((e) {
     print(e.details);
     alert(context, "The email address that you provided is not "
      "available, maybe other users are using the same "
      "email address, try to use other email address.");
     // code, message, details
    });
   } else {
    alert(context, "The passwords do not match");
   }
  }
 }

 static void registerProfile(BuildContext context, GlobalKey<FormState> formKey,
  TextEditingController fullNameInputCtrl,
  TextEditingController addressInputCtrl,
  String selectedCountryCode,
  TextEditingController contactNumberInputCtrl,
  DateTime selectedDate,
  String profilePhotoURL) async {
  String userID = await getCurrentUser();

  String birthday = (selectedDate.toLocal().month.toString() +"/"+
   selectedDate.toLocal().day.toString() +"/"+
   selectedDate.toLocal().year.toString()).split(' ')[0];
  if (formKey.currentState.validate()) {
   if (fullNameInputCtrl.text != "" && addressInputCtrl.text != ""
    && contactNumberInputCtrl.text != "" && birthday != "" && profilePhotoURL != null
   ) {
    Firestore.instance
     .collection("users")
     .document(userID.toString())
     .updateData({
     "full_name": fullNameInputCtrl.text,
     "address": addressInputCtrl.text,
     "birth_date": birthday,
     "contact_number": selectedCountryCode+contactNumberInputCtrl.text,
     "profile_photo_url": profilePhotoURL,
    }).whenComplete(() {
       Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => DashBoard())
       );
    }).catchError((err) {
       print(err.details);
       alert(context, "Error uploading information, check your internet.");
    }
    );
   } else {
    alert(context, "Fill in all the necessary information to be able to finish step 2 of registration.");
   }
  }
 }

 static void updateProfile(BuildContext context, GlobalKey<FormState> formKey,
  TextEditingController fullNameInputCtrl,
  TextEditingController addressInputCtrl,
  TextEditingController contactNumberInputCtrl,
  TextEditingController birthdayInputCtrl,
  String profilePhotoURL) async {
  String userID = await getCurrentUser();

  if (formKey.currentState.validate()) {
   if (fullNameInputCtrl.text != "" && addressInputCtrl.text != ""
    && contactNumberInputCtrl.text != "" && birthdayInputCtrl.text != "" && profilePhotoURL != null
   ) {
    Firestore.instance
     .collection("users")
     .document(userID.toString())
     .updateData({
     "full_name": fullNameInputCtrl.text,
     "address": addressInputCtrl.text,
     "birth_date": birthdayInputCtrl.text,
     "contact_number": contactNumberInputCtrl.text,
     "profile_photo_url": profilePhotoURL,
    }).whenComplete(() {
     Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => DashBoard())
     );
    }).catchError((err) {
     print(err.details);
     alert(context, "Error uploading information, check your internet.");
    }
    );
   } else {
    alert(context, "Fill in all the necessary information to be able to finish step 2 of registration.");
   }
  }
 }
}



class User {

 static Future<String> getName(String userID) async{
  DocumentSnapshot query = await Firestore.instance.collection('users').document(userID).get();
  String fullName;

  fullName = query.data['full_name'];

  return fullName;
 }

 static Future<String> getBirthdate(String userID) async {
  DocumentSnapshot query = await Firestore.instance.collection('users').document(userID).get();
  String birthDate;

  birthDate = query.data['birth_date'];

  return birthDate;
 }

 static Future<String> getContactNumber(String userID) async {
  DocumentSnapshot query = await Firestore.instance.collection('users').document(userID).get();
  String contactNumber;

  contactNumber = query.data['contact_number'];

  return contactNumber;
 }

 static Future<String> getAddress(String userID) async {
  DocumentSnapshot query = await Firestore.instance.collection('users').document(userID).get();
  String address;

  address = query.data['address'];

  return address;
 }

 static Future<String> getEmailAddress(String userID) async {
  DocumentSnapshot query = await Firestore.instance.collection('users').document(userID).get();
  String email;

  email = query.data['email'];

  return email;
 }

 static Future<String> getProfilePhoto(String userID) async {
  DocumentSnapshot query = await Firestore.instance.collection('users').document(userID).get();
  String profilePhotoURL;

  profilePhotoURL = query.data['profile_photo_url'];

  return profilePhotoURL;
 }

}

class SmallClip extends CustomClipper<Rect> {
 Rect getClip(Size size) {
  return Rect.fromCircle(center: Offset(20, 20), radius: 20);
 }

 @override
 bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
  return false;
 }
}

class LargeClip extends CustomClipper<Rect> {
 Rect getClip(Size size) {
  return Rect.fromCircle(center: Offset(20, 20), radius: 20);
 }

 @override
 bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
  return false;
 }
}