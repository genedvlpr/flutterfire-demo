import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire/utils/styles.dart';
import 'package:flutterfire/utils/util.dart';

class RegistrationCredentials extends StatefulWidget {
  RegistrationCredentials({Key key}) : super(key: key);


  @override
  _RegistrationCredentialsState createState() {
    return _RegistrationCredentialsState();
  }
}

class _RegistrationCredentialsState extends State<RegistrationCredentials> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;

  bool uploading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Toggles the password show status
  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
  void _toggleConfirmPassword() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Text(
                    "Register",
                    textAlign: TextAlign.left,
                    style: themeData(context).textTheme.headline6,
                  ),

                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Register an email address and create a password.",
                    textAlign: TextAlign.left,
                    style: themeData(context).textTheme.bodyText2,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    decoration: InputDecoration(


                      //focusColor: Color(0xFF2960fc),
                      icon: Icon(Icons.person,),
                      hintText: 'Use any email accounts',
                      labelText: 'Email *',
                    ),
                    controller: emailInputController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Utils.emailValidator,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(icon: Icon(Icons.remove_red_eye),
                        onPressed: (){
                          _togglePassword();
                        },),
                      icon: Icon(Icons.dialpad,),
                      hintText: 'Must be 8 characters',
                      labelText: 'Password *',
                    ),
                    controller: pwdInputController,
                    obscureText: _obscurePassword,
                    validator: Utils.passwordValidator,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(icon: Icon(Icons.remove_red_eye),
                        onPressed: (){
                          _toggleConfirmPassword();
                        },),
                      icon: Icon(Icons.dialpad,),
                      hintText: 'Must be 8 characters',
                      labelText: 'Password *',
                    ),
                    controller: confirmPwdInputController,
                    obscureText: _obscureConfirmPassword,
                    validator: Utils.passwordValidator,
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
                         "Step 1"
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


                            if (_formKey.currentState.validate()) {
                              Utils.registerCredentials(context, _formKey, emailInputController, pwdInputController, confirmPwdInputController, uploading);
                            }
                          },
                          child: Icon(Icons.chevron_right, color: themeData(context).primaryColorLight,),
                          backgroundColor: themeData(context).primaryColorDark,
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}