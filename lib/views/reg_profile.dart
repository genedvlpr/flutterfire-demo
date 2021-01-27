import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire/utils/styles.dart';
import 'package:flutterfire/utils/util.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'dart:io';
import 'package:path/path.dart' as path;
class RegistrationProfile extends StatefulWidget {
  RegistrationProfile({Key key}) : super(key: key);


  @override
  _RegistrationProfileState createState() {
    return _RegistrationProfileState();
  }
}

class _RegistrationProfileState extends State<RegistrationProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController fullNameInputController;
  TextEditingController addressInputController;
  TextEditingController ageInputController;
  TextEditingController contactNumberInputController;
  TextEditingController phoneInputController;

  bool uploading = false;

  File _imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    fullNameInputController = new TextEditingController();
    addressInputController = new TextEditingController();
    ageInputController = new TextEditingController();
    contactNumberInputController = new TextEditingController();
    phoneInputController = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String birthday = "";
  String profilePhotoURL = "";

  DateTime selectedDate = DateTime(DateTime.now().year-12);

  String selectedCountryCode;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
     context: context,
     initialDate: DateTime(DateTime.now().year-12),
     firstDate: DateTime(1960),
     lastDate: DateTime(DateTime.now().year-12));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Widget _buildDropdownItem(Country country) => Container(
    child: Row(
      children: <Widget>[
        //CountryPickerUtils.getDefaultFlagImage(country),
        //SizedBox(
          //width: 8.0,
        //),
        Text("+${country.phoneCode}(${country.isoCode})"),
      ],
    ),
  );


  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future uploadProfilePhoto(BuildContext context) async {
    String userID = await Utils.getCurrentUser();
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
            Utils.registerProfile(context, _formKey, fullNameInputController,
            addressInputController, selectedCountryCode,
            phoneInputController, selectedDate, profilePhotoURL, )
         }
       },
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
     body: Form(
       key: _formKey,
       child: Center(
         child: SingleChildScrollView (
           padding: const EdgeInsets.all(40.0),
           child: Center(
             child: new Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[

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
                             "Register",
                             textAlign: TextAlign.left,
                             style: themeData(context).textTheme.headline6,
                           ),
                           SizedBox(
                             height: 15,
                           ),
                           Text(
                             "Fill in your first name, last name and your middle name.",
                             textAlign: TextAlign.left,
                             style: themeData(context).textTheme.bodyText2,
                           ),
                         ],
                       )
                     ),
                     _imageFile != null ?
                     CircleAvatar(
                       backgroundColor: Theme.of(context).canvasColor,
                       child: ClipOval(
                         //clipper: LargeClip(),
                         child: Image.file(_imageFile, fit: BoxFit.cover,
                           height: 140,
                           width: 140,),
                       ),radius: 60,
                     ): Container(
                       padding: EdgeInsets.all(25),
                       child: IconButton(
                         iconSize: 72,
                         color: themeData(context).primaryColorDark,
                         icon: Icon(Icons.add_photo_alternate_rounded, color: themeData(context).accentColor,),
                         onPressed: () {
                           pickImage();
                         },
                       ),
                     ),
                   ],
                 ),

                 SizedBox(
                   height: 15,
                 ),
                 TextFormField(
                   decoration: const InputDecoration(

                     //focusColor: Color(0xFF2960fc),
                     icon: Icon(Icons.person, ),
                     hintText: 'Enter your first name',
                     labelText: 'Full Name*',
                   ),
                   validator: Utils.nameValidator,
                   controller: fullNameInputController,
                   keyboardType: TextInputType.text,
                 ),
                 SizedBox(
                   height: 15,
                 ),
                 TextFormField(
                   decoration: const InputDecoration(

                     //focusColor: Color(0xFF2960fc),
                     icon: Icon(Icons.my_location, ),
                     hintText: 'Enter your address',
                     labelText: 'Address*',
                   ),
                   controller: addressInputController,
                   keyboardType: TextInputType.text,
                   validator: Utils.addressValidator,
                 ),
                 SizedBox(
                   height: 15,
                 ),

                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[

                     Icon(
                       Icons.cake,
                       color: themeData(context).primaryColor,
                       size: 24.0,
                     ),
                     Text( (DateTime.now().year - selectedDate.toLocal().year).toString()+" yrs.",
                       textAlign: TextAlign.left,
                       style: TextStyle(fontSize: 16),
                     ),
                     SizedBox(
                       width: 0,
                     ),
                     FlatButton.icon(
                       icon: Icon(Icons.today, color: themeData(context).primaryColor,),
                       label: Text(
                         "Birthday: ${selectedDate.toLocal().month}"+"/"+"${selectedDate.toLocal().day}"
                          +"/"+"${selectedDate.toLocal().year}".split(' ')[0],
                         textAlign: TextAlign.left,
                         style: TextStyle(color: themeData(context).primaryColor),
                       ),
                       splashColor: themeData(context).primaryColor,
                       onPressed:  () => _selectDate(context),
                       focusColor: themeData(context).primaryColorLight,
                       hoverColor: themeData(context).primaryColorLight,
                       highlightColor: themeData(context).primaryColorLight,
                     ),
                   ],
                 ),
                 SizedBox(
                   height: 15,
                 ),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[

                     SizedBox(
                       child: CountryPickerDropdown(
                         initialValue: 'ph',
                         itemBuilder: _buildDropdownItem,
                         onValuePicked: (Country country) {
                           print("${country.name}");
                           selectedCountryCode = "${country.phoneCode}";
                           setState(() { selectedCountryCode = "${country
                            .phoneCode}";});
                           print(selectedCountryCode);
                         },
                       ),
                     ),

                     SizedBox(
                       child: TextFormField(
                         decoration: InputDecoration(
                           icon: null,
                           hintText: 'Enter your phone no.',
                           labelText: 'Phone*',
                           prefixText: selectedCountryCode == null ||
                            selectedCountryCode == "" ?
                           selectedCountryCode ="+63" :
                           selectedCountryCode,
                         ),
                         controller: phoneInputController,
                         validator: Utils.phoneValidator,
                         keyboardType: TextInputType.number,
                         maxLength: 10,
                         inputFormatters: <TextInputFormatter>[
                           WhitelistingTextInputFormatter.digitsOnly
                         ], // Only
                       ),
                     ),
                   ],


                 ),
                 SizedBox(
                   height: 25,
                 ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[
                     Align(
                       alignment: Alignment.centerLeft,
                       child: Text(
                        "Step 2"
                       ),
                     ),
                     Align(
                       alignment: Alignment.center,
                       child: Container(
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.centerLeft,
                        child:  uploading == true ? SpinKitThreeBounce(
                          color: Colors.blueAccent[400],
                          size: 20.0,
                        ) : null
                       ),

                     ),
                     Align(
                       alignment: Alignment.center,
                       child: FloatingActionButton(
                         onPressed: () async {
                           uploadProfilePhoto(context);
                         },
                         child: Icon(Icons.chevron_right, color: themeData(context).primaryColorLight,),
                         backgroundColor: themeData(context).primaryColorDark,
                       ),
                     ),

                   ],
                 )
               ],
             ),
           ),
         ),
       ),
     )
    );
  }
}