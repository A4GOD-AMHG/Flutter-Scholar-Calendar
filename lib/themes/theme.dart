import 'package:flutter/material.dart';

///[splashColor] color de marca usado en la pantalla de carga y el splash nativo
const splashColor = Color(0xFF06296B);

const _brand = Color(0xFF094C90);

final _scheme = ColorScheme.fromSeed(
  seedColor: _brand,
  brightness: Brightness.dark,
);

final _radius = BorderRadius.circular(16);

///[dark] tema oscuro (Material 3) de la aplicación
ThemeData dark = ThemeData(
  useMaterial3: true,
  colorScheme: _scheme,
  scaffoldBackgroundColor: _scheme.surface,
  appBarTheme: const AppBarTheme(
    backgroundColor: _brand,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 2,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _scheme.primaryContainer,
    foregroundColor: _scheme.onPrimaryContainer,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: _scheme.surfaceContainerHigh,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: _scheme.surfaceContainerLow,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _scheme.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  cardTheme: CardThemeData(
    color: _scheme.surfaceContainer,
    elevation: 0,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: _radius),
  ),
  listTileTheme: ListTileThemeData(
    iconColor: _scheme.onSurfaceVariant,
    shape: RoundedRectangleBorder(borderRadius: _radius),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  drawerTheme: DrawerThemeData(backgroundColor: _scheme.surfaceContainerLow),
);
