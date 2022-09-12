import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';

import '../Theme/app_theme_data.dart';
import '../shared_preferences/preferences.dart';

class AppThemeState extends ChangeNotifier {
  AppThemeState(this.read);

  final Reader read;

  late ThemeData _lightThemeData;
  ThemeData get lightThemeData => _lightThemeData;

  late ThemeData _darkThemeData;
  ThemeData get darkThemeData => _darkThemeData;

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  late final Preferences readPreferencesProviderValue =
      read(preferencesProvider);

  init({ColorScheme? lightDynamic, ColorScheme? darkDynamic}) {
    _lightThemeData = AppThemeData.lightThemeData(lightDynamic);
    _darkThemeData = AppThemeData.darkThemeData(darkDynamic);
    _themeMode = readPreferencesProviderValue.themeMode;
  }

  updateThemeMode() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
      readPreferencesProviderValue.persistThemeMode(ThemeMode.system);
    } else if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      readPreferencesProviderValue.persistThemeMode(ThemeMode.dark);
    } else {
      _themeMode = ThemeMode.light;
      readPreferencesProviderValue.persistThemeMode(ThemeMode.light);
    }
    notifyListeners();
  }
}
