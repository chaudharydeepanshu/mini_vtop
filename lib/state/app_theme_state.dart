import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/ui/theme/app_theme_data.dart';
import 'package:minivtop/shared_preferences/preferences.dart';

class AppThemeState extends ChangeNotifier {
  AppThemeState(this.ref);

  final Ref ref;

  late Color _userColorSchemeSeedColor;
  Color get userColorSchemeSeedColor => _userColorSchemeSeedColor;

  late ColorScheme? _lightDynamicColorScheme;
  ColorScheme? get lightDynamicColorScheme => _lightDynamicColorScheme;

  late ColorScheme? _darkDynamicColorScheme;
  ColorScheme? get darkDynamicColorScheme => _darkDynamicColorScheme;

  late ColorScheme? _appLightColorScheme;
  ColorScheme? get appLightColorScheme => _appLightColorScheme;

  late ColorScheme? _appDarkColorScheme;
  ColorScheme? get appDarkColorScheme => _appDarkColorScheme;

  late ColorScheme _userLightColorScheme;
  ColorScheme get userLightColorScheme => _userLightColorScheme;

  late ColorScheme _userDarkColorScheme;
  ColorScheme get userDarkColorScheme => _userDarkColorScheme;

  late ThemeData _lightThemeData;
  ThemeData get lightThemeData => _lightThemeData;

  late ThemeData _darkThemeData;
  ThemeData get darkThemeData => _darkThemeData;

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  late bool _isDynamicThemeEnabled;
  bool get isDynamicThemeEnabled => _isDynamicThemeEnabled;

  late final Preferences readPreferencesProviderValue =
      ref.read(preferencesProvider);

  initTheme({ColorScheme? lightDynamic, ColorScheme? darkDynamic}) {
    _lightDynamicColorScheme = lightDynamic;
    _darkDynamicColorScheme = darkDynamic;
    _isDynamicThemeEnabled = readPreferencesProviderValue.dynamicThemeStatus;
    int seedColorColorValue =
        readPreferencesProviderValue.userThemeSeedColorValue;
    _userColorSchemeSeedColor = Color(seedColorColorValue);
    _userLightColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: _userColorSchemeSeedColor,
    );
    //     SeedColorScheme.fromSeeds(
    //   brightness: Brightness.light,
    //   primaryKey: seedColor,
    //   tones: FlexTones.vivid(Brightness.light),
    // );
    _userDarkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: _userColorSchemeSeedColor,
    );
    //     SeedColorScheme.fromSeeds(
    //   brightness: Brightness.dark,
    //   primaryKey: seedColor,
    //   tones: FlexTones.vivid(Brightness.dark),
    // );

    if ((_lightDynamicColorScheme != null || _darkDynamicColorScheme != null) &&
        _isDynamicThemeEnabled == true) {
      _appLightColorScheme = _lightDynamicColorScheme;
      _appDarkColorScheme = _darkDynamicColorScheme;
    } else {
      _appLightColorScheme = _userLightColorScheme;
      _appDarkColorScheme = _userDarkColorScheme;
    }

    _lightThemeData = AppThemeData.lightThemeData(_appLightColorScheme);
    _darkThemeData = AppThemeData.darkThemeData(_appDarkColorScheme);
    _themeMode = readPreferencesProviderValue.themeMode;
  }

  updateTheme() {
    initTheme(
        lightDynamic: _lightDynamicColorScheme,
        darkDynamic: _darkDynamicColorScheme);

    if ((_lightDynamicColorScheme != null || _darkDynamicColorScheme != null) &&
        isDynamicThemeEnabled == true) {
      _lightThemeData = AppThemeData.lightThemeData(_lightDynamicColorScheme);
      _darkThemeData = AppThemeData.darkThemeData(_darkDynamicColorScheme);
    } else {
      _lightThemeData = AppThemeData.lightThemeData(_userLightColorScheme);
      _darkThemeData = AppThemeData.darkThemeData(_userDarkColorScheme);
    }
    _themeMode = readPreferencesProviderValue.themeMode;
    notifyListeners();
  }

  updateDynamicThemeStatus() {
    _isDynamicThemeEnabled = !_isDynamicThemeEnabled;
    readPreferencesProviderValue
        .persistDynamicThemeStatus(_isDynamicThemeEnabled);

    updateTheme();
    notifyListeners();
  }

  updateUserTheme(Color newUserThemeColor) {
    readPreferencesProviderValue
        .persistUserThemeSeedColorValue(newUserThemeColor.value);

    _userLightColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: newUserThemeColor,
    );
    //     SeedColorScheme.fromSeeds(
    //   brightness: Brightness.light,
    //   primaryKey: newUserThemeColor,
    //   tones: FlexTones.vivid(Brightness.light),
    // );
    _userDarkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: newUserThemeColor,
    );
    //     SeedColorScheme.fromSeeds(
    //   brightness: Brightness.dark,
    //   primaryKey: newUserThemeColor,
    //   tones: FlexTones.vivid(Brightness.dark),
    // );
    updateTheme();
    notifyListeners();
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
