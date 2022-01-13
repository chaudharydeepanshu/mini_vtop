import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_vtop/coreFunctions/sign_out.dart';

chooseCorrectAppbar(
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
    required ValueChanged<bool> onRefreshingCaptcha,
    required ValueChanged<bool> onProcessingSomething,
    required ValueChanged<String> onCurrentFullUrl,
    required ValueChanged<String> onUserEnteredUname,
    required ValueChanged<String> onUserEnteredPasswd,
    required ValueChanged<Widget> onAppbar}) async {
  if (currentStatus == null) {
    onAppbar.call(
      AppBar(
        title: Text(
          "Headless Testing",
          style: GoogleFonts.nunito(),
        ),
        actions: const [],
        backgroundColor: const Color(0xFFF1D3BB),
      ),
    );
  } else if (currentStatus == "launchLoadingScreen") {
    onAppbar.call(
      AppBar(
        key: const ValueKey<int>(0),
        elevation: 0,
        centerTitle: true,
        title: Container(
          decoration: const BoxDecoration(
            color: Color(0xff04294f),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "VIT Bhopal - VTOP",
              style: GoogleFonts.nunito(
                color: Colors.white,
                textStyle: Theme.of(context).textTheme.headline1,
                fontSize: 25,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        backgroundColor: Colors.white10,
      ),
    );
  } else if (currentStatus == "signInScreen") {
    onAppbar.call(
      AppBar(
        key: const ValueKey<int>(1),
        // elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Student Sign-In",
            style: GoogleFonts.nunito(
              color: Colors.white,
              textStyle: Theme.of(context).textTheme.headline1,
              fontSize: 25,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: const Color(0xff04294f),
      ),
    );
  } else if (currentStatus == "userLoggedIn") {
    onAppbar.call(
      AppBar(
        centerTitle: true,
        title: Text(
          "Student Portal",
          style: GoogleFonts.nunito(
            color: Colors.white,
            textStyle: Theme.of(context).textTheme.headline1,
            fontSize: 25,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xff04294f),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5, top: 8, bottom: 8),
            child: SizedBox(
              width: 51,
              height: 40,
              child: Material(
                color: Colors.transparent,
                shape: const StadiumBorder(),
                child: Tooltip(
                  message: "Logout",
                  child: InkWell(
                    onTap: () {
                      performSignOut(
                          context: context,
                          headlessWebView: headlessWebView,
                          onCurrentFullUrl: (String value) {
                            onCurrentFullUrl.call(value);
                          });
                    },
                    customBorder: const StadiumBorder(),
                    focusColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.1),
                    splashColor: Colors.white.withOpacity(0.1),
                    hoverColor: Colors.white.withOpacity(0.1),
                    child: const Icon(
                      Icons.logout,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
