import 'package:flutter/material.dart';

class AppColors {
  // Define your color constants here
//  static const Color primaryColor = Color(0xFF274C77); // #274C77
//  static const Color secondaryColor = Color(0xFF6096BA); // #6096BA
//  static const Color backgroundColor = Color(0xFFE7ECEF); // #E7ECEF
//  static const Color textColor = Color(0xFF8B8C89); // #8B8C89
//  static const Color accentColor = Color(0xFFA3CEF1); // #A3CEF1

  static ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
  );
  static ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
  );
}
