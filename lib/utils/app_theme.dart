import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: GoogleFonts.interTextTheme(),
    primarySwatch: Colors.indigo,
    useMaterial3: true,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: GoogleFonts.interTextTheme(),
    primarySwatch: Colors.indigo,
    useMaterial3: true,
  );
}
