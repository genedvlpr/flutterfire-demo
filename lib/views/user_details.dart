import 'package:flutter/material.dart';
import 'package:flutterfire/utils/styles.dart';
import 'package:flutterfire/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class UserDetails extends StatefulWidget {
  UserDetails({Key key, this.userID, this.profilePhotoURL, this.editMode}) : super(key: key);

  final String userID, profilePhotoURL;
  final bool editMode;
  @override
  _UserDetailsState createState() {
    return _UserDetailsState();
  }
}

class _UserDetailsState extends State<UserDetails> {

  TextEditingController fullNameInputController;
  TextEditingController emailInputController;
  TextEditingController addressInputController;
  TextEditingController birthDayInputController;
  TextEditingController contactNumberInputController;
  TextEditingController phoneInputController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool editMode = false;
  File _imageFile;
  final picker = ImagePicker();
  String profilePhotoURL = "";
  @override
  void initState() {
    fullNameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    addressInputController = new TextEditingController();
    birthDayInputController = new TextEditingController();
    contactNumberInputController = new TextEditingController();
    phoneInputController = new TextEditingController();


    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getData() async {
   String fullName = await User.getName(widget.userID);
   String email = await User.getEmailAddress(widget.userID);
   String address = await User.getAddress(widget.userID);
   String birthday = await User.getBirthdate(widget.userID);
   String contactNumber = await User.getContactNumber(widget.userID);

   fullNameInputController.text = fullName;
   emailInputController.text = email;
   addressInputController.text = address;
   birthDayInputController.text = birthday;
   contactNumberInputController.text = contactNumber;
  }

  void editAccount() async {
   setState(() {
     editMode = true;
   });
  }

  void updateAccount() async {
   uploadProfilePhoto(context);
  }

  Future pickImage() async {
   final pickedFile = await picker.getImage(source: ImageSource.gallery);

   setState(() {
    _imageFile = File(pickedFile.path);
   });
  }

  Future uploadProfilePhoto(BuildContext context) async {
   String userID = await Utils.getCurrentUser();

   if(_imageFile != null){
    String fileName = path.basename(_imageFile.path);
    StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('profile_photo/$userID/$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL().then(
      (value) => {
      setState((){
       profilePhotoURL = value;
      }),
      if (_formKey.currentState.validate()) {
       Utils.updateProfile(context, _formKey, fullNameInputController,
        addressInputController, contactNumberInputController, birthDayInputController,
        profilePhotoURL, )
      }
     },
    );
   } else {
     Utils.updateProfile(context, _formKey, fullNameInputController,
      addressInputController, contactNumberInputController, birthDayInputController,
      widget.profilePhotoURL, );
   }

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   getData();
    return Scaffold(
     body: Form(
      key: _formKey,
      child: SingleChildScrollView(
       child: Container(
        padding: EdgeInsets.all(25),
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
          SizedBox(
           height: 75,
          ),
          Row(
           crossAxisAlignment: CrossAxisAlignment.center,
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
            SizedBox(
             width: 140,
             child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Text(
                "Account\nDetails",
                textAlign: TextAlign.left,
                style: themeData(context).textTheme.headline6,
               ),

               SizedBox(
                height: 15,
               ),
               Text(
                "These are the information of this account.",
                textAlign: TextAlign.left,
                style: themeData(context).textTheme.bodyText2,
               ),
              ],
             )
            ),

            //profile_photo_url != null ?

            Stack(
             children: [
              CircleAvatar(
               backgroundColor: Theme.of(context).canvasColor,
               child: ClipOval(
                //clipper: LargeClip(),
                child:editMode || widget.editMode  ?
                _imageFile != null ?
                Image.file(_imageFile, fit: BoxFit.cover,
                 height: 140,
                 width: 140,): Container():
                CachedNetworkImage(
                 colorBlendMode: BlendMode.srcOver,
                 color: Colors.black12,
                 // here `bytes` is a Uint8List containing the bytes for the in-memory image

                 imageUrl:widget.profilePhotoURL,
                 fit: BoxFit.cover,
                 height: 140,
                 width: 140,
                ),
               ),radius: 60,
              ),
              editMode || widget.editMode && _imageFile == null  ?
              Container(
               padding: EdgeInsets.all(25),
               child: IconButton(
                iconSize: 56,
                color: _imageFile == null ? themeData(context).accentColor :
                themeData(context).primaryColorLight,
                icon: Icon(Icons.add_photo_alternate_rounded,
                 color: _imageFile == null ? themeData(context).accentColor :
                 themeData(context).primaryColorLight,),
                onPressed: () {
                 pickImage();
                },
               ),
              ) : Container()
             ],
            )

           ],
          ),

          SizedBox(
           height: 15,
          ),
          TextFormField(
           decoration: InputDecoration(

            //focusColor: Color(0xFF2960fc),
            icon: Icon(Icons.person, color: themeData(context).primaryColorDark, ),
            hintText: "",
            labelText: 'Full Name*',
           ),
           enabled: editMode || widget.editMode ? true : false,
           controller: fullNameInputController,
           keyboardType: TextInputType.text,
          ),
          SizedBox(
           height: 15,
          ),
          TextFormField(
           decoration: InputDecoration(

            //focusColor: Color(0xFF2960fc),
            icon: Icon(Icons.mail, color: themeData(context).primaryColorDark, ),
            hintText: "",
            labelText: 'Email',
           ),
           enabled: false,
           controller: emailInputController,
           keyboardType: TextInputType.text,
          ),
          SizedBox(
           height: 15,
          ),
          TextFormField(
           decoration: InputDecoration(

            //focusColor: Color(0xFF2960fc),
            icon: Icon(Icons.location_on, color: themeData(context).primaryColorDark, ),
            hintText: "",
            labelText: 'Address',
           ),
           enabled: editMode || widget.editMode ? true : false,
           controller: addressInputController,
           keyboardType: TextInputType.text,
          ),
          SizedBox(
           height: 15,
          ),
          TextFormField(
           decoration: InputDecoration(

            //focusColor: Color(0xFF2960fc),
            icon: Icon(Icons.face_rounded, color: themeData(context).primaryColorDark, ),
            hintText: "",
            labelText: 'Birthday',
           ),
           enabled: editMode || widget.editMode ? true : false,
           controller: birthDayInputController,
           keyboardType: TextInputType.text,
          ),
          SizedBox(
           height: 15,
          ),
          TextFormField(
           decoration: InputDecoration(

            //focusColor: Color(0xFF2960fc),
            icon: Icon(Icons.phone, color: themeData(context).primaryColorDark, ),
            hintText: "",
            labelText: 'Contact Number',
           ),
           enabled: editMode || widget.editMode ? true : false,
           controller: contactNumberInputController,
           keyboardType: TextInputType.text,
          ),
          SizedBox(
           height: 35,
          ),

          editMode || widget.editMode ?
          RaisedButton.icon(
           onPressed: (){
            updateAccount();
           },
           shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
           ),
           icon: Icon(Icons.cloud_upload_rounded, color: Colors.white,),
           color: themeData(context).primaryColorDark,
           label: new Text(
            'Update Account',
            style: TextStyle(fontSize: 20, color: Colors.white)
           ),
          ):
          RaisedButton.icon(
           onPressed: (){
            editAccount();
           },
           shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
           ),
           icon: Icon(Icons.edit, color: Colors.white,),
           color: themeData(context).accentColor,
           label: new Text(
            'Edit Account',
            style: TextStyle(fontSize: 20, color: Colors.white)
           ),
          )
         ],
        ),
       ),
      ),
     )
    );
  }
}