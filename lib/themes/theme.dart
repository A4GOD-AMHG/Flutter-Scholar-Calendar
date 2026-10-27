import 'package:flutter/material.dart';

ThemeData dark = ThemeData.dark().copyWith(
  primaryColor: const Color(0xFF06296B),
  colorScheme: ThemeData.dark().colorScheme.copyWith(
        surface: const Color(0xFF272727),
        onSurface: const Color(0xDCDCDCDC),
        surfaceContainerHigh: const Color(0xFF373739),
      ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF052C53),
    foregroundColor: Color(0xC9C9C9C9),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(const Color(0xDCDCDCDC)),
    ),
  ),
  iconTheme: const IconThemeData(color: Color(0xDCDCDCDC)),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF094C90),
    titleTextStyle: TextStyle(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    foregroundColor: Colors.white,
  ),
);
