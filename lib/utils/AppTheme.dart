import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme with ChangeNotifier {
  static Color primaryColor = Color.fromRGBO(72, 52, 212, 1);
  static Color accentColor = primaryColor;

  static ThemeData _customThemeLight = ThemeData(
      brightness: Brightness.light,
      canvasColor: Color.fromRGBO(242, 243, 248, 1),
      primaryColor: primaryColor,
      accentColor: accentColor
  );
  static ThemeData customThemeLight = _customThemeLight.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(_customThemeLight.textTheme)
  );

  static ThemeData _customThemeDark = ThemeData(
      brightness: Brightness.dark,
      canvasColor: Colors.black,
      cardColor: Color.fromRGBO(10, 10, 10, 1),
      primaryColor: primaryColor,
      accentColor: accentColor
  );
  static ThemeData customThemeDark = _customThemeDark.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(_customThemeDark.textTheme)
  );

  static bool _isDark = true;

  AppTheme() {
    SharedPreferences.getInstance().then((prefs) {
      _isDark = prefs.getBool("enableDarkTheme") ?? true;
      notifyListeners();
    });
  }


  ThemeData currentTheme(){
    return _isDark ? customThemeDark : customThemeLight;
  }

  void switchTheme(){
    _isDark = !_isDark;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("enableDarkTheme", _isDark);
    });
    notifyListeners();
  }

  bool isDark() => _isDark;
}