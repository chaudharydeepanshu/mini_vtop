import 'package:minivtop/state/package_info_state.dart';
import 'package:minivtop/state/user_login_state.dart';
import 'package:minivtop/state/vtop_actions.dart';
import 'package:minivtop/state/vtop_controller_state.dart';
import 'package:minivtop/state/vtop_data_state.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared_preferences/preferences.dart';
import 'app_theme_state.dart';
import 'connection_state.dart';
import 'error_state.dart';
import 'webview_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

late final PackageInfo packageInfo;
late final SharedPreferences sharedPreferencesInstance;

Future<void> initPackageInfo() async {
  packageInfo = await PackageInfo.fromPlatform();
}

Future<void> initSharedPreferences() async {
  sharedPreferencesInstance = await SharedPreferences.getInstance();
}

final packageInfoCalcProvider =
    ChangeNotifierProvider((ref) => PackageInfoCalc()..init(packageInfo));

final preferencesProvider = ChangeNotifierProvider(
    (ref) => Preferences(ref)..init(sharedPreferencesInstance));

final appThemeStateProvider =
    ChangeNotifierProvider((ref) => AppThemeState(ref)..initTheme());

final vtopControllerStateProvider =
    ChangeNotifierProvider((ref) => VTOPControllerState(ref)..init());

final userLoginStateProvider =
    ChangeNotifierProvider((ref) => UserLoginState()..init());

final headlessWebViewProvider =
    ChangeNotifierProvider((ref) => HeadlessWebView(ref)..init());

final connectionStatusStateProvider =
    ChangeNotifierProvider((ref) => ConnectionStatusState()..init());

final vtopActionsProvider = ChangeNotifierProvider((ref) => VTOPActions(ref));

final vtopDataProvider = ChangeNotifierProvider((ref) => VTOPData(ref));

final errorStatusStateProvider =
    ChangeNotifierProvider((ref) => ErrorStatusState(ref)..init());
