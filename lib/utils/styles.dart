import 'dart:ui';

import 'package:flutter/material.dart';

ThemeData themeData(BuildContext context) {


 Color colorPrimary = Colors.amber[500];
 Color colorPrimaryLight = Colors.grey[50];
 Color colorPrimaryDark = Colors.amber[800];
 Color colorAccent = Colors.blue[500];
 Color colorBodyText1 = Colors.grey[800];
 Color colorBodyText2 = Colors.grey[500];
 Color colorForeground = Colors.grey[50];

 return ThemeData(
  brightness: Brightness.light,
  primaryColor: colorPrimary,
  accentColor: colorAccent,
  primaryColorDark: colorPrimaryDark,
  unselectedWidgetColor: Colors.black12,
  buttonColor: colorAccent,
  splashColor: colorAccent.withAlpha(36),
  buttonTheme: ButtonThemeData(buttonColor: colorAccent, textTheme: ButtonTextTheme.normal ),
  dialogBackgroundColor:  Theme.of(context).canvasColor,
  textTheme: TextTheme(
    headline4: TextStyle(color: colorPrimary, fontSize: 48.0, fontWeight: FontWeight.bold),
    headline5: TextStyle(color: colorPrimary, fontSize: 42.0, fontWeight: FontWeight.bold),
    headline6: TextStyle(color: colorPrimary, fontSize: 36.0, fontWeight: FontWeight.bold),
    bodyText1: TextStyle(color: colorBodyText1,fontSize: 24.0, fontWeight: FontWeight.normal),
    bodyText2: TextStyle(color: colorBodyText2,fontSize: 18.0, fontWeight: FontWeight.normal),
    button: TextStyle(color: colorForeground,fontSize: 24.0, fontWeight: FontWeight.normal)
  ),
  primaryColorLight: colorPrimaryLight,
 );

}