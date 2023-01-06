import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/main.dart';
import 'package:minivtop/state/package_info_state.dart';
import 'package:minivtop/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

String themeModePerfKey = "themeMode";
String userThemeSeedColorValuePerfKey = "userThemeSeedColorValue";
String dynamicThemeStatusPerfKey = "dynamicThemeStatus";
String crashlyticsCollectionStatusPerfKey = 'crashlyticsCollectionStatus';
String analyticsCollectionStatusPerfKey = 'analyticsCollectionStatus';

class Preferences extends ChangeNotifier {
  Preferences(this.ref);
  final Ref ref;

  late SharedPreferences _sharedPreferences;
  SharedPreferences get sharedPreferences => _sharedPreferences;

  late final PackageInfoCalc readPackageInfoCalcProviderValue =
      ref.read(packageInfoCalcProvider);

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
      '{"attendanceID":"BL2022233", "timeTableID":"BL2022233"}';

  persistAppVersion(String version) =>
      sharedPreferences.setString('appVersion', version);

  String? get appVersion => sharedPreferences.getString('appVersion');

  persistThemeMode(ThemeMode mode) =>
      sharedPreferences.setString(themeModePerfKey, mode.toString());

  ThemeMode get themeMode => ThemeMode.values.firstWhere(
        (element) =>
            element.toString() == sharedPreferences.getString(themeModePerfKey),
        orElse: () => ThemeMode.light,
      );

  persistUserThemeSeedColorValue(int userThemeSeedColorValue) =>
      sharedPreferences.setInt(
          userThemeSeedColorValuePerfKey, userThemeSeedColorValue);

  int get userThemeSeedColorValue =>
      sharedPreferences.getInt(userThemeSeedColorValuePerfKey) ??
      const Color(0xFFA93054).value;

  persistDynamicThemeStatus(bool dynamicThemeStatus) =>
      sharedPreferences.setBool(dynamicThemeStatusPerfKey, dynamicThemeStatus);

  bool get dynamicThemeStatus =>
      sharedPreferences.getBool(dynamicThemeStatusPerfKey) ?? true;

  /// For persisting crashlytics collection status in SharedPreferences.
  static Future<bool> persistCrashlyticsCollectionStatus(
    final bool crashlyticsCollectionStatus,
  ) async {
    await crashlyticsInstance.setCrashlyticsCollectionEnabled(
      crashlyticsCollectionStatus,
    );
    return sharedPreferencesInstance.setBool(
      crashlyticsCollectionStatusPerfKey,
      crashlyticsCollectionStatus,
    );
  }

  /// For getting crashlytics collection status from SharedPreferences.
  static bool get crashlyticsCollectionStatus =>
      sharedPreferencesInstance.getBool(crashlyticsCollectionStatusPerfKey) ??
      true;

  /// For persisting analytics collection status in SharedPreferences.
  static Future<bool> persistAnalyticsCollectionStatus(
    final bool analyticsCollectionStatus,
  ) async {
    await analyticsInstance.setAnalyticsCollectionEnabled(
      analyticsCollectionStatus,
    );
    return sharedPreferencesInstance.setBool(
      analyticsCollectionStatusPerfKey,
      analyticsCollectionStatus,
    );
  }

  /// For getting analytics collection status from SharedPreferences.
  static bool get analyticsCollectionStatus =>
      sharedPreferencesInstance.getBool(analyticsCollectionStatusPerfKey) ??
      true;

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
