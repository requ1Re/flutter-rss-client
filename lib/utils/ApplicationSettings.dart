import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationSettings with ChangeNotifier {
  static Color primaryColor = Color.fromRGBO(72, 52, 212, 1);
  static Color primaryColorDark = Color.fromRGBO(110, 89, 255, 1.0);
  static Color accentColor = primaryColor;

  static ThemeData _customThemeLight = ThemeData(
      brightness: Brightness.light,
      canvasColor: Color.fromRGBO(242, 243, 248, 1),
      primaryColor: primaryColor,
      accentColor: accentColor,
      textTheme: TextTheme(
        bodyText2: TextStyle(color: Colors.grey[800]),
        subtitle1: TextStyle(color: Colors.black)
      )
  );
  static ThemeData customThemeLight = _customThemeLight.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(_customThemeLight.textTheme)
  );

  static ThemeData _customThemeDark = ThemeData(
      brightness: Brightness.dark,
      canvasColor: Color(0xFF2e2f36),
      cardColor: Color.fromRGBO(20, 20, 20, 1),
      primaryColor: primaryColorDark,
      accentColor: primaryColorDark,
      textTheme: TextTheme(
        bodyText2: TextStyle(color: Color(0xFF959abd)),
        subtitle1: TextStyle(color: Colors.white)
      )
  );
  static ThemeData customThemeDark = _customThemeDark.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(_customThemeDark.textTheme)
  );


  // Settings
  static bool _darkTheme = true;
  static bool _offlineMode = false;

  static final ApplicationSettings _instance = ApplicationSettings._internal();
  factory ApplicationSettings() => _instance;

  ApplicationSettings._internal() {
    SharedPreferences.getInstance().then((prefs) {
      _darkTheme = prefs.getBool("enableDarkTheme") ?? _darkTheme;
      _offlineMode = prefs.getBool("enableOfflineMode") ?? _offlineMode;
      notifyListeners();
    });
  }


  ThemeData currentTheme() {
    return _darkTheme ? customThemeDark : customThemeLight;
  }

  void toggleDarkTheme() {
    setEnableDarkMode(!_darkTheme);
  }

  void setEnableDarkMode(bool enableDarkMode){
    _darkTheme = enableDarkMode;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("enableDarkTheme", _darkTheme);
      notifyListeners();
    });
    print("[DEBUG] Updated Setting: Dark Theme");
  }

  void toggleOfflineMode(){
    setEnableOfflineMode(!_offlineMode);
  }

  void setEnableOfflineMode(bool enableOfflineMode){
    _offlineMode = enableOfflineMode;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("enableOfflineMode", _offlineMode);
      notifyListeners();
    });
    print("[DEBUG] Updated Setting: Offline Mode");
  }

  bool isDarkThemeEnabled() => _darkTheme;
  bool isOfflineModeEnabled() => _offlineMode;
}
