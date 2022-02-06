import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';

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
      AppBar(
        key: const ValueKey<int>(0),
        // elevation: 0,
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            "VIT Bhopal - VTOP",
            style: GoogleFonts.nunito(
              color: Colors.white,
              textStyle: Theme.of(context).textTheme.headline1,
              fontSize: screenBasedPixelWidth * 25,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: const Color(0xff04294f),
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(right: 5, top: 8, bottom: 8),
            child: SizedBox(
              width: screenBasedPixelWidth * 51,
              height: screenBasedPixelWidth * 40,
              child: Material(
                color: Colors.transparent,
                shape: const StadiumBorder(),
                child: Tooltip(
                  message: "Open Drawer",
                  child: InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                      // onCurrentStatus.call("originalVTOP");
                    },
                    customBorder: const StadiumBorder(),
                    focusColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.1),
                    splashColor: Colors.white.withOpacity(0.1),
                    hoverColor: Colors.white.withOpacity(0.1),
                    child: Icon(
                      Icons.menu,
                      size: screenBasedPixelWidth * 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  } else if (currentStatus == "signInScreen") {
    onAppbar.call(
      AppBar(
        key: const ValueKey<int>(1),
        // elevation: 0,
        centerTitle: true,
        title: Text(
          "Student Sign-In",
          style: GoogleFonts.nunito(
            color: Colors.white,
            textStyle: Theme.of(context).textTheme.headline1,
            fontSize: screenBasedPixelWidth * 25,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xff04294f),

        leading: Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.only(
                right: screenBasedPixelWidth * 5,
                top: screenBasedPixelWidth * 8,
                bottom: screenBasedPixelWidth * 8),
            child: SizedBox(
              width: screenBasedPixelWidth * 51,
              height: screenBasedPixelHeight * 40,
              child: Material(
                color: Colors.transparent,
                shape: const StadiumBorder(),
                child: Tooltip(
                  message: "Open Drawer",
                  child: InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                      // onCurrentStatus.call("originalVTOP");
                    },
                    customBorder: const StadiumBorder(),
                    focusColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.1),
                    splashColor: Colors.white.withOpacity(0.1),
                    hoverColor: Colors.white.withOpacity(0.1),
                    child: Icon(
                      Icons.menu,
                      size: screenBasedPixelWidth * 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  } else if (currentStatus == "userLoggedIn") {
    onAppbar.call(
      AppBar(
        // toolbarHeight: screenBasedPixelHeight * 56,
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            "Student Portal",
            style: GoogleFonts.nunito(
              color: Colors.white,
              textStyle: Theme.of(context).textTheme.headline1,
              fontSize: screenBasedPixelWidth * 25,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: const Color(0xff04294f),
        leading: Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.only(
                right: screenBasedPixelWidth * 5,
                top: screenBasedPixelWidth * 8,
                bottom: screenBasedPixelWidth * 8),
            child: SizedBox(
              width: screenBasedPixelWidth * 51,
              height: screenBasedPixelWidth * 40,
              child: Material(
                color: Colors.transparent,
                shape: const StadiumBorder(),
                child: Tooltip(
                  message: "Open Drawer",
                  child: InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                      // onCurrentStatus.call("originalVTOP");
                    },
                    customBorder: const StadiumBorder(),
                    focusColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.1),
                    splashColor: Colors.white.withOpacity(0.1),
                    hoverColor: Colors.white.withOpacity(0.1),
                    child: Icon(
                      Icons.menu,
                      size: screenBasedPixelWidth * 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 5, top: 8, bottom: 8),
        //     child: SizedBox(
        //       width: 51,
        //       height: 40,
        //       child: Material(
        //         color: Colors.transparent,
        //         shape: const StadiumBorder(),
        //         child: Tooltip(
        //           message: "Logout",
        //           child: InkWell(
        //             onTap: () {
        //               performSignOut(
        //                   context: context,
        //                   headlessWebView: headlessWebView,
        //                   onCurrentFullUrl: (String value) {
        //                     onCurrentFullUrl.call(value);
        //                   });
        //             },
        //             customBorder: const StadiumBorder(),
        //             focusColor: Colors.white.withOpacity(0.1),
        //             highlightColor: Colors.white.withOpacity(0.1),
        //             splashColor: Colors.white.withOpacity(0.1),
        //             hoverColor: Colors.white.withOpacity(0.1),
        //             child: const Icon(
        //               Icons.logout,
        //               size: 24,
        //               color: Colors.white,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   )
        // ],
      ),
    );
  } else if (currentStatus == "originalVTOP") {
    onAppbar.call(
      AppBar(
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            "Original VTOP",
            style: GoogleFonts.nunito(
              color: Colors.white,
              textStyle: Theme.of(context).textTheme.headline1,
              fontSize: screenBasedPixelWidth * 25,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: const Color(0xff04294f),
        leading: Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.only(
                right: screenBasedPixelWidth * 5,
                top: screenBasedPixelWidth * 8,
                bottom: screenBasedPixelWidth * 8),
            child: SizedBox(
              width: screenBasedPixelWidth * 51,
              height: screenBasedPixelWidth * 40,
              child: Material(
                color: Colors.transparent,
                shape: const StadiumBorder(),
                child: Tooltip(
                  message: "Open Drawer",
                  child: InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                      // onCurrentStatus.call("userLoggedIn");
                    },
                    customBorder: const StadiumBorder(),
                    focusColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.1),
                    splashColor: Colors.white.withOpacity(0.1),
                    hoverColor: Colors.white.withOpacity(0.1),
                    child: Icon(
                      Icons.menu,
                      size: screenBasedPixelWidth * 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 5, top: 8, bottom: 8),
        //     child: SizedBox(
        //       width: 51,
        //       height: 40,
        //       child: Material(
        //         color: Colors.transparent,
        //         shape: const StadiumBorder(),
        //         child: Tooltip(
        //           message: "Logout",
        //           child: InkWell(
        //             onTap: () {
        //               performSignOut(
        //                   context: context,
        //                   headlessWebView: headlessWebView,
        //                   onCurrentFullUrl: (String value) {
        //                     onCurrentFullUrl.call(value);
        //                   });
        //             },
        //             customBorder: const StadiumBorder(),
        //             focusColor: Colors.white.withOpacity(0.1),
        //             highlightColor: Colors.white.withOpacity(0.1),
        //             splashColor: Colors.white.withOpacity(0.1),
        //             hoverColor: Colors.white.withOpacity(0.1),
        //             child: const Icon(
        //               Icons.logout,
        //               size: 24,
        //               color: Colors.white,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   )
        // ],
      ),
    );
  }
}
