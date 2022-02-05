import 'package:shared_preferences/shared_preferences.dart';

Future<int?> retrieveSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  // Check where the name is saved before or not
  if (!prefs.containsKey('savedThemeModeIndex')) {
    //if not return zero for ThemeMode.System
    return 0;
  }
  //else return the saved theme
  return prefs.getInt('savedThemeModeIndex')!;
}

Future<void> saveThemeMode(int themeModeIndex) async {
  final prefs = await SharedPreferences.getInstance();
  // Save ThemeMode index
  prefs.setInt('savedThemeModeIndex', themeModeIndex);
}
