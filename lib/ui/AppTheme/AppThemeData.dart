import 'package:flutter/material.dart';

class ThemeClass {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    platform: TargetPlatform.android,
    scaffoldBackgroundColor: Colors.white,
    primaryTextTheme: const TextTheme(
      headline6: TextStyle(color: Colors.black),
    ),
    //iconTheme: IconThemeData(color: Colors.black),
    cardTheme: CardTheme(
      color: Colors.grey.shade400,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade300,
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.grey.shade300,
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    // iconTheme: IconThemeData(color: Colors.black),
    // scaffoldBackgroundColor: Color(0xFF121212),
    // canvasColor: Color(0xFF121212),
    checkboxTheme: CheckboxThemeData(
      checkColor: MaterialStateProperty.all(Colors.white),
      fillColor: MaterialStateProperty.all(Colors.lightBlueAccent),
    ),
    cardTheme: const CardTheme(
      color: Color(0xff424242),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF222222),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: Color(0xFF222222),
    ),
  );
}
