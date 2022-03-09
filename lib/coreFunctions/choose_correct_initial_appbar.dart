import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';

import '../basicFunctionsAndWidgets/widget_size_limiter.dart';

chooseCorrectAppbar({
  required BuildContext context,
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
  required var scaffoldKey,
  required ValueChanged<bool> onRefreshingCaptcha,
  required ValueChanged<bool> onProcessingSomething,
  required ValueChanged<String> onCurrentFullUrl,
  required ValueChanged<String> onCurrentStatus,
  required ValueChanged<String> onUserEnteredUname,
  required ValueChanged<String> onUserEnteredPasswd,
  required ValueChanged<Widget> onAppbar,
  required ValueChanged<String> onError,
}) async {
  if (currentStatus == null) {
    onAppbar.call(
      AppBar(
        title: Text(
          "Headless Testing",
          style: GoogleFonts.nunito(),
        ),
        actions: const [],
        backgroundColor: const Color(0xFFF1D3BB),
        automaticallyImplyLeading: false,
      ),
    );
  } else if (currentStatus == "launchLoadingScreen") {
    onAppbar.call(
      CustomMainScreenAppBar(
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
        appBarTitleText: "VIT Bhopal - VTOP",
        appBarValueKey: const ValueKey<int>(0),
      ),
    );
  } else if (currentStatus == "signInScreen") {
    onAppbar.call(
      CustomMainScreenAppBar(
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
        appBarTitleText: "Student Portal",
        appBarValueKey: const ValueKey<int>(1),
      ),
    );
  } else if (currentStatus == "userLoggedIn") {
    onAppbar.call(
      CustomMainScreenAppBar(
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
        appBarTitleText: "Student Sign-In",
        // appBarValueKey: const ValueKey<int>(2),
      ),
    );
  } else if (currentStatus == "originalVTOP") {
    onAppbar.call(
      CustomMainScreenAppBar(
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
        appBarTitleText: "Original VTOP",
        // appBarValueKey: const ValueKey<int>(3),
      ),
    );
  }
}

class CustomMainScreenAppBar extends StatelessWidget {
  const CustomMainScreenAppBar({
    Key? key,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
    required this.appBarTitleText,
    this.appBarValueKey,
  }) : super(key: key);

  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;
  final String appBarTitleText;
  final ValueKey? appBarValueKey;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: appBarValueKey,
      // elevation: 5,
      centerTitle: true,
      title: Text(
        appBarTitleText,
        style: getDynamicTextStyle(
            textStyle: Theme.of(context).appBarTheme.titleTextStyle,
            sizeDecidingVariable: screenBasedPixelWidth),
        textAlign: TextAlign.center,
      ),
      // backgroundColor: Theme.of(context).colorScheme.surface,
      leading: Builder(
        builder: (context) => OutlinedButton(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              getDynamicTextStyle(
                  textStyle: Theme.of(context).appBarTheme.titleTextStyle,
                  sizeDecidingVariable: screenBasedPixelWidth),
            ),
            side: MaterialStateProperty.all<BorderSide>(
                const BorderSide(color: Colors.transparent)),
            shape:
                MaterialStateProperty.all<StadiumBorder>(const StadiumBorder()),
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          child: Icon(
            Icons.menu,
            size: widgetSizeProvider(
                fixedSize: 24, sizeDecidingVariable: screenBasedPixelWidth),
          ),
        ),
      ),
    );
  }
}
