import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mini_vtop/ui/drawer.dart';

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
        onthemeMode: (ThemeMode value) {
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
        onthemeMode: (ThemeMode value) {
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
        onthemeMode: (ThemeMode value) {
          onThemeMode?.call(value);
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
        onthemeMode: (ThemeMode value) {
          onThemeMode?.call(value);
        },
      ),
    );
  }
}
