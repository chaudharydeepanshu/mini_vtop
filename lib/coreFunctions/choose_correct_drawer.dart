import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mini_vtop/ui/drawer.dart';

chooseCorrectDrawer(
    {required BuildContext context,
    required String? currentStatus,
    required String? loggedUserStatus,
    required HeadlessInAppWebView? headlessWebView,
    required String userEnteredUname,
    required String userEnteredPasswd,
    required bool processingSomething,
    required Image? image,
    required bool refreshingCaptcha,
    required String currentFullUrl,
    required AdaptiveThemeMode? savedThemeMode,
    required ValueChanged<bool> onRefreshingCaptcha,
    required ValueChanged<bool> onProcessingSomething,
    required ValueChanged<String> onCurrentFullUrl,
    required ValueChanged<String> onCurrentStatus,
    required ValueChanged<String> onUserEnteredUname,
    required ValueChanged<String> onUserEnteredPasswd,
    required ValueChanged<Widget?> onDrawer}) async {
  if (currentStatus == null) {
    onDrawer.call(
      null,
    );
  } else if (currentStatus == "launchLoadingScreen") {
    onDrawer.call(
      null,
    );
  } else if (currentStatus == "signInScreen") {
    onDrawer.call(
      CustomDrawer(
        savedThemeMode: savedThemeMode,
      ),
    );
  } else if (currentStatus == "userLoggedIn") {
    onDrawer.call(
      CustomDrawer(
        savedThemeMode: savedThemeMode,
      ),
    );
  } else if (currentStatus == "originalVTOP") {
    onDrawer.call(
      CustomDrawer(
        savedThemeMode: savedThemeMode,
      ),
    );
  }
}
