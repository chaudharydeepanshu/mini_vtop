import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mini_vtop/ui/drawer.dart';

import 'call_student_profile_all_view.dart';

chooseCorrectDrawer(
    {required BuildContext context,
    required double screenBasedPixelWidth,
    required double screenBasedPixelHeight,
    required String? currentStatus,
    required String? loggedUserStatus,
    required HeadlessInAppWebView? headlessWebView,
    required String userEnteredUname,
    required String userEnteredPasswd,
    required bool processingSomething,
    required Image? image,
    required bool refreshingCaptcha,
    required String currentFullUrl,
    required ThemeMode? themeMode,
    required ValueChanged<bool> onTryAutoLoginStatus,
    required ValueChanged<String> onRequestType,
    required ValueChanged<ThemeMode>? onThemeMode,
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
      CustomDrawer(
        themeMode: themeMode,
        currentStatus: currentStatus,
        onCurrentStatus: (String value) {
          onCurrentStatus.call(value);
        },
        onCurrentFullUrl: (String value) {
          onCurrentFullUrl.call(value);
        },
        headlessWebView: headlessWebView,
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
        onThemeMode: (ThemeMode value) {
          onThemeMode?.call(value);
        },
      ),
    );
  } else if (currentStatus == "signInScreen") {
    onDrawer.call(
      CustomDrawer(
        themeMode: themeMode,
        currentStatus: currentStatus,
        onCurrentStatus: (String value) {
          onCurrentStatus.call(value);
        },
        onCurrentFullUrl: (String value) {
          onCurrentFullUrl.call(value);
        },
        headlessWebView: headlessWebView,
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
        onThemeMode: (ThemeMode value) {
          onThemeMode?.call(value);
        },
      ),
    );
  } else if (currentStatus == "userLoggedIn") {
    onDrawer.call(
      CustomDrawer(
        themeMode: themeMode,
        currentStatus: currentStatus,
        onCurrentStatus: (String value) {
          onCurrentStatus.call(value);
        },
        onCurrentFullUrl: (String value) {
          onCurrentFullUrl.call(value);
        },
        headlessWebView: headlessWebView,
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
        onThemeMode: (ThemeMode value) {
          onThemeMode?.call(value);
        },
        onShowStudentProfileAllView: (bool value) {
          onRequestType.call("Fake");
          callStudentProfileAllView(
            context: context,
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl.call(value);
            },
            processingSomething: value,
            onProcessingSomething: (bool value) {
              onProcessingSomething.call(value);
            },
          );
        },
        onTryAutoLoginStatus: (bool value) {
          onTryAutoLoginStatus.call(value);
        },
      ),
    );
  } else if (currentStatus == "originalVTOP") {
    onDrawer.call(
      CustomDrawer(
        themeMode: themeMode,
        currentStatus: currentStatus,
        onCurrentStatus: (String value) {
          onCurrentStatus.call(value);
        },
        onCurrentFullUrl: (String value) {
          onCurrentFullUrl.call(value);
        },
        headlessWebView: headlessWebView,
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
        onThemeMode: (ThemeMode value) {
          onThemeMode?.call(value);
        },
        onShowStudentProfileAllView: (bool value) {
          onRequestType.call("Fake");
          callStudentProfileAllView(
            context: context,
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl.call(value);
            },
            processingSomething: value,
            onProcessingSomething: (bool value) {
              onProcessingSomething.call(value);
            },
          );
        },
        onTryAutoLoginStatus: (bool value) {
          onTryAutoLoginStatus.call(value);
        },
      ),
    );
  }
}
