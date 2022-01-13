import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mini_vtop/coreFunctions/call_time_table.dart';
import 'package:mini_vtop/coreFunctions/sign_in.dart';
import 'package:mini_vtop/coreFunctions/sign_out.dart';
import 'package:mini_vtop/ui/launch_loading_screen.dart';
import '../first_body.dart';
import '../login_body.dart';
import '../student_portal.dart';
import 'call_student_profile_all_view.dart';
import 'captcha_refresh.dart';
import 'forHeadlessInAppWebView/run_headless_in_app_web_view.dart';
import 'forHeadlessInAppWebView/show_console_message.dart';
import 'forHeadlessInAppWebView/stop_headless_in_app_web_view.dart';

chooseCorrectBody(
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
    required String? vtopStatusType,
    required String vtopLoginErrorType,
    required String? studentName,
    required String autoCaptcha,
    required DateTime? sessionDateTime,
    required var studentPortalDocument,
    required var studentProfileAllViewDocument,
    required bool tryAutoLoginStatus,
    required ValueChanged<bool> onRetryOnError,
    required ValueChanged<bool> onClearUnamePasswd,
    required ValueChanged<bool> onTryAutoLoginStatus,
    required ValueChanged<String> onRequestType,
    required ValueChanged<bool> onRefreshingCaptcha,
    required ValueChanged<bool> onProcessingSomething,
    required ValueChanged<String> onCurrentFullUrl,
    required ValueChanged<String> onUserEnteredUname,
    required ValueChanged<String> onUserEnteredPasswd,
    required ValueChanged<String> onVtopLoginErrorType,
    required ValueChanged<Widget> onBody,
    required bool credentialsFound}) async {
  if (currentStatus == null) {
    onBody.call(
      RunHeadlessInAppWebView(
        onCurrentStatus: (String value) {
          if (value == "runHeadlessInAppWebView") {
            runHeadlessInAppWebView(
                onCurrentFullUrl: (String value) {
                  onCurrentFullUrl.call(value);
                },
                headlessWebView: headlessWebView);
          } else if (value == "stopHeadlessInAppWebView") {
            stopHeadlessInAppWebView(
                onCurrentFullUrl: (String value) {
                  onCurrentFullUrl.call(value);
                },
                headlessWebView: headlessWebView);
          }
        },
        onConsoleMessage: (bool value) {
          showConsoleMessage(
              context: context, headlessWebView: headlessWebView);
        },
        arguments: RunHeadlessInAppWebViewArguments(
          currentStatus: currentStatus,
        ),
      ),
    );
  } else if (currentStatus == "launchLoadingScreen") {
    onBody.call(
      LaunchLoadingScreen(
        key: const ValueKey<int>(0),
        onCurrentFullUrl: (String value) {
          onCurrentFullUrl.call(value);
        },
        arguments: LaunchLoadingScreenArguments(
            vtopStatusType: vtopStatusType, headlessWebView: headlessWebView),
        onRetryOnError: (bool value) {
          onRetryOnError.call(value);
        },
      ),
    );
  } else if (currentStatus == "signInScreen") {
    onBody.call(LoginSection(
      key: const ValueKey<int>(1),
      onPerformSignIn: (Map value) {
        performSignIn(
            processingSomething: value["processingSomething"],
            uname: value["uname"],
            passwd: value["passwd"],
            captchaCheck: value["captchaCheck"],
            context: context,
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl.call(value);
            },
            refreshingCaptcha: value["refreshingCaptcha"],
            onRefreshingCaptcha: (bool value) {
              onRefreshingCaptcha.call(value);
            },
            onProcessingSomething: (bool value) {
              onProcessingSomething.call(value);
            });
        onUserEnteredUname.call(value["uname"]);
        onUserEnteredPasswd.call(value["passwd"]);
      },
      onPerformSignOut: (bool value) {
        performSignOut(
            context: context,
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl.call(value);
            });
      },
      onRefreshCaptcha: (Map value) {
        onUserEnteredUname.call(value["uname"]);
        onUserEnteredPasswd.call(value["passwd"]);
        performCaptchaRefresh(
            headlessWebView: headlessWebView,
            context: context,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl.call(value);
            },
            refreshingCaptcha: value["refreshingCaptcha"],
            onRefreshingCaptcha: (bool value) {
              onRefreshingCaptcha.call(value);
            });
      },
      arguments: LoginSectionArguments(
        // headlessWebView: headlessWebView!,
        tryAutoLoginStatus: tryAutoLoginStatus,
        currentFullUrl: currentFullUrl,
        processingSomething: processingSomething,
        image: image,
        currentStatus: currentStatus,
        userEnteredUname: userEnteredUname,
        userEnteredPasswd: userEnteredPasswd,
        autoCaptcha: autoCaptcha,
        refreshingCaptcha: refreshingCaptcha,
        vtopLoginErrorType: vtopLoginErrorType,
        credentialsFound: credentialsFound,
      ),
      onVtopLoginErrorType: (String value) {
        onVtopLoginErrorType.call(value);
      },
      onClearUnamePasswd: (bool value) {
        onClearUnamePasswd.call(value);
      },
      onTryAutoLoginStatus: (bool value) {
        onTryAutoLoginStatus.call(value);
      },
    ));
  } else if (currentStatus == "userLoggedIn") {
    // await headlessWebView?.webViewController
    //     .evaluateJavascript(
    //         source: "new XMLSerializer().serializeToString(document);")
    //     .then((value) {
    //   printWrapped(value);
    // });
    onBody.call(
      StudentPortal(
        loggedUserStatus: loggedUserStatus,
        onShowStudentProfileAllView: (bool value) {
          onRequestType.call("Real");
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
        onTimeTable: (bool value) {
          onRequestType.call("Real");
          callTimeTable(
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
        arguments: StudentPortalArguments(
            processingSomething: processingSomething,
            studentPortalDocument: studentPortalDocument,
            studentProfileAllViewDocument: studentProfileAllViewDocument,
            headlessWebView: headlessWebView,
            studentName: studentName,
            sessionDateTime: sessionDateTime),
      ),
    );
    // if (currentStatus == "userLoggedIn" &&
    //     loggedUserStatus == "StudentProfileAllView") {
    //   Navigator.pushNamed(
    //     context,
    //     PageRoutes.studentProfileAllView,
    //     arguments: StudentProfileAllViewArguments(
    //       currentStatus: currentStatus,
    //     ),
    //   );
    // }
  }
}
