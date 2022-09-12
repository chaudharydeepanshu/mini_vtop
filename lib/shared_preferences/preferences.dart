import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/package_info_state.dart';
import '../state/providers.dart';

class Preferences extends ChangeNotifier {
  Preferences(this.read);
  final Reader read;

  late SharedPreferences _sharedPreferences;
  SharedPreferences get sharedPreferences => _sharedPreferences;

  late final PackageInfoCalc readPackageInfoCalcProviderValue =
      read(packageInfoCalcProvider);

  init(SharedPreferences sharedPreferencesInstance) async {
    _sharedPreferences = sharedPreferencesInstance;

    String? sharedPerfAppVersion = sharedPreferences.getString('appVersion');
    String? packageAppVersion = readPackageInfoCalcProviderValue.version;
    if (sharedPerfAppVersion != packageAppVersion) {
      log("App version($packageAppVersion) and shred perf($sharedPerfAppVersion)version are not same. So clearing perf.");
      // Clearing old app perf
      await _sharedPreferences.remove('studentProfileHTMLDoc');
      await _sharedPreferences.remove('academicsHTMLDoc');
      // Updating perf app version
      persistAppVersion(packageAppVersion);
    } else {
      log("App version($packageAppVersion) and shred perf($sharedPerfAppVersion) version are same. So not clearing perf.");
    }
  }

  persistVTOPController(String vtopController) =>
      sharedPreferences.setString('vtopController', vtopController);

  String get vtopController =>
      sharedPreferences.getString('vtopController') ??
      '{"attendanceID":"BL2022231", "timeTableID":"BL2022231"}';

  persistAppVersion(String version) =>
      sharedPreferences.setString('appVersion', version);

  String? get appVersion => sharedPreferences.getString('appVersion');

  persistThemeMode(ThemeMode mode) =>
      sharedPreferences.setString('themeMode', mode.toString());

  ThemeMode get themeMode => ThemeMode.values.firstWhere(
        (element) =>
            element.toString() == sharedPreferences.getString('themeMode'),
        orElse: () => ThemeMode.system,
      );

  persistStudentProfileHTMLDoc(String doc) =>
      sharedPreferences.setString('studentProfileHTMLDoc', doc);

  String? get studentProfileHTMLDoc =>
      sharedPreferences.getString('studentProfileHTMLDoc');

  persistAcademicsHTMLDoc(String doc) =>
      sharedPreferences.setString('academicsHTMLDoc', doc);

  String? get academicsHTMLDoc =>
      sharedPreferences.getString('academicsHTMLDoc');

  persistAttendanceHTMLDoc(String doc) =>
      sharedPreferences.setString('attendanceHTMLDoc', doc);

  String? get attendanceHTMLDoc =>
      sharedPreferences.getString('attendanceHTMLDoc');

  persistTimeTableHTMLDoc(String doc) =>
      sharedPreferences.setString('timeTableHTMLDoc', doc);

  String? get timeTableHTMLDoc =>
      sharedPreferences.getString('timeTableHTMLDoc');
}
