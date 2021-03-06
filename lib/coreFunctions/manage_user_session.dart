import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'call_student_profile_all_view.dart';
import 'forHeadlessInAppWebView/run_headless_in_app_web_view.dart';

void manageUserSession({
  required BuildContext context,
  required HeadlessInAppWebView? headlessWebView,
  required ValueChanged<String> onCurrentFullUrl,
  required ValueChanged<bool> onProcessingSomething,
  required ValueChanged<String> onError,
  required ValueChanged<String> onRequestType,
}) async {
  if (headlessWebView?.isRunning() ?? false) {
    await headlessWebView?.webViewController
        .evaluateJavascript(
            source: "new XMLSerializer().serializeToString(document);")
        .then((value) async {
      // printWrapped(value);
      if (value.contains(
              "You are logged out due to inactivity for more than 15 minutes") ||
          value.contains("You have been successfully logged out")) {
        debugPrint(
            "You are logged out due to inactivity for more than 15 minutes");
        debugPrint(
            "called inactivityResponse or successfullyLoggedOut Action https://vtop.vitbhopal.ac.in/vtop for manageUserSession");
        runHeadlessInAppWebView(
          headlessWebView: headlessWebView,
          onCurrentFullUrl: (String value) {
            onCurrentFullUrl(value);
          },
        );
      } else {
        Timer.periodic(const Duration(minutes: 10), (timer) {
          onRequestType.call("Fake");
          callStudentProfileAllView(
            context: context,
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl.call(value);
            },
            processingSomething: false,
            onProcessingSomething: (bool value) {
              onProcessingSomething.call(value);
            },
            onError: (String value) {
              onError.call(value);
            },
          );
        });

        await headlessWebView.webViewController.evaluateJavascript(source: '''
const initialTime = Date.now();
const menuToggle = document.querySelector("#menu-toggle");
if (menuToggle !== null) {
    const doSomething = () => {
        var winImage = document.querySelector("#winImage")?.value;
        var authorizedID = document.querySelector("#authorizedID")?.value;
        fetch(
            "https://vtop.vitbhopal.ac.in/vtop/studentsRecord/StudentProfileAllView",
            {
                headers: {
                    accept: "*/*",
                    "accept-language": "en-US,en;q=0.9",
                    "content-type":
                        "application/x-www-form-urlencoded; charset=UTF-8",
                    "sec-fetch-dest": "empty",
                    "sec-fetch-mode": "cors",
                    "sec-fetch-site": "same-origin",
                    "sec-gpc": "1",
                    "x-requested-with": "XMLHttpRequest",
                },
                referrer: "https://vtop.vitbhopal.ac.in/vtop/initialProcess",
                referrerPolicy: "strict-origin-when-cross-origin",
                body: `verifyMenu=true&winImage=\${winImage}&authorizedID=\${authorizedID}&nocache=@(new Date().getTime())`,
                method: "POST",
                mode: "cors",
                credentials: "include",
            }
        ).then((res) =>
            console.log((Date.now() - initialTime) / 1000, res.status, res)
        );
    };
    doSomething();
    setInterval(() => {
        doSomething();
    }, 10 * 60 * 1000);

              ''');
        debugPrint("called manageUserSession");
      }
    });
  } else {
    const snackBar = SnackBar(
      content: Text(
          'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!'),
      duration: Duration(milliseconds: 1500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
