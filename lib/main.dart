import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterfire/utils/styles.dart';
import 'package:flutterfire/utils/util.dart';
import 'package:flutterfire/views/reg_credentials.dart';
import 'package:flutterfire/views/dashboard.dart';

void main() {
  runApp(FlutterFire());
}

class FlutterFire extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterFire',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: LoginPage(title: 'Login'),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;
  TextEditingController pwdInputController;

  bool signingIn = false;

  bool _obscurePassword = true;

  @override
  initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();


    super.initState();
  }
  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void checkUser() async{
    if(await Utils.getCurrentUser() != null ||
       await Utils.getCurrentUser() != ""){
          Navigator.pushReplacement(context, MaterialPageRoute(
           builder: (context) => DashBoard())
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    checkUser();
    return Scaffold(
     body: Form(
       key: _loginFormKey,
       child: Center(
         child: SingleChildScrollView (
           child: Center(
             child: new Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[

                 Container(
                   padding: const EdgeInsets.all(40.0),
                   child:
                   Column(
                     children: [
                       Text(
                         "Login your account",
                         textAlign: TextAlign.left,
                         style: themeData(context).textTheme.headline6,
                       ),

                       SizedBox(
                         height: 15,
                       ),
                       Text(
                         "Fill in your email or username and your password.",
                         textAlign: TextAlign.left,
                         style: themeData(context).textTheme.bodyText2,
                       ),
                       SizedBox(
                         height: 50,
                       ),
                       TextFormField(
                         decoration: const InputDecoration(

                           //focusColor: Color(0xFF2960fc),
                           icon: Icon(Icons.person, ),
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
                           icon: Icon(Icons.dialpad, ),
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
                       Wrap(
                         alignment: WrapAlignment.center,
                         children: <Widget>[
                           SizedBox(
                             width: double.maxFinite,
                             child: RaisedButton.icon(
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(8.0),
                               ),
                               onPressed: () {
                                 Utils.loginUser(context, _loginFormKey, emailInputController, pwdInputController);
                                 },
                               icon: Icon(Icons.verified_user, color: Colors.white,),
                               label: new Text(
                                'Login',
                                style: TextStyle(fontSize: 20, color: Colors.white)
                               ),
                               color: themeData(context).primaryColor,
                             ),
                           ),

                           SizedBox(
                             width: double.maxFinite  ,
                             child: OutlineButton.icon(
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(8.0),
                               ),
                               onPressed: () {
                                 Navigator.pushReplacement(context, MaterialPageRoute(
                                  builder: (context) => RegistrationCredentials())
                                 );
                               },
                               icon: Icon(Icons.backup, color: themeData(context).accentColor,),
                               label: new Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 20, color: themeData(context).accentColor)
                               ),
                               color: themeData(context).accentColor,
                               splashColor: themeData(context).splashColor,
                               hoverColor: Colors.transparent,
                               highlightColor: Colors.transparent,
                               focusColor: Colors.transparent,
                               highlightedBorderColor: themeData(context).accentColor,
                             ),
                           ),

                         ],
                       ),
                       Align(
                         alignment: Alignment.center,
                         child: Container(
                          padding: EdgeInsets.all(0),
                          alignment: Alignment.centerLeft,
                          child:  signingIn == true ?
                          SpinKitThreeBounce(
                            color: Colors.blueAccent[400],
                            size: 20.0,
                          ) : null
                         ),

                       ),
                     ],
                   ),
                 ),
               ],
             ),
           ),


         ),
       ),
     )
    );
  }
}
