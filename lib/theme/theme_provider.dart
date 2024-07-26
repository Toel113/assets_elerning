import 'package:assets_elerning/theme/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themedata = ligthmode;

  ThemeData get themeData => _themedata;

  set themeData(ThemeData themeData) {
    _themedata = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themedata == ligthmode) {
      themeData = darkMode;
    } else {
      themeData = ligthmode;
    }
  }
}
