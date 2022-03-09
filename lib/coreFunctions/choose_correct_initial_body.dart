import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mini_vtop/coreFunctions/call_class_attendance.dart';
import 'package:mini_vtop/coreFunctions/call_time_table.dart';
import 'package:mini_vtop/coreFunctions/sign_in.dart';
import 'package:mini_vtop/coreFunctions/sign_out.dart';
import 'package:mini_vtop/ui/first_body.dart';
import 'package:mini_vtop/ui/launch_loading_screen.dart';
import '../ui/full_webview.dart';
import '../ui/login_body.dart';
import '../ui/student_portal.dart';
import 'call_student_profile_all_view.dart';
import 'captcha_refresh.dart';
import 'forHeadlessInAppWebView/run_headless_in_app_web_view.dart';
import 'forHeadlessInAppWebView/show_console_message.dart';
import 'forHeadlessInAppWebView/stop_headless_in_app_web_view.dart';

chooseCorrectBody(
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
    required String vtopConnectionStatusType,
    required String vtopConnectionStatusErrorType,
    required String vtopLoginErrorType,
    required String? studentName,
    required String autoCaptcha,
    required DateTime? sessionDateTime,
    required var studentPortalDocument,
    required var studentProfileAllViewDocument,
    required bool tryAutoLoginStatus,
    required ThemeMode? themeMode,
    required ValueChanged<ThemeMode>? onThemeMode,
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
    required ValueChanged<String> onError,
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
            context: context,
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl.call(value);
            },
          );
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
          vtopConnectionStatusType: vtopConnectionStatusType,
          headlessWebView: headlessWebView,
          screenBasedPixelWidth: screenBasedPixelWidth,
          screenBasedPixelHeight: screenBasedPixelHeight,
          vtopConnectionStatusErrorType: vtopConnectionStatusErrorType,
          onProcessingSomething: (bool value) {
            onProcessingSomething.call(value);
          },
        ),
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
          },
          onError: (String value) {
            onError.call(value);
          },
        );
        onUserEnteredUname.call(value["uname"]);
        onUserEnteredPasswd.call(value["passwd"]);
      },
      onPerformSignOut: (bool value) {
        performSignOut(
          context: context,
          headlessWebView: headlessWebView,
          onCurrentFullUrl: (String value) {
            onCurrentFullUrl.call(value);
          },
          onError: (String value) {
            onError.call(value);
          },
        );
      },
      onRefreshCaptcha: (Map value) {
        onUserEnteredUname.call(value["uname"]);
        onUserEnteredPasswd.call(value["passwd"]);
        onRefreshingCaptcha.call(true);
        performCaptchaRefresh(
          headlessWebView: headlessWebView,
          context: context,
          onCurrentFullUrl: (String value) {
            onCurrentFullUrl.call(value);
          },
          refreshingCaptcha: value["refreshingCaptcha"],
          onError: (String value) {
            onError.call(value);
          },
          onRefreshingCaptcha: (bool value) {
            onRefreshingCaptcha.call(value);
          },
        );
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
        screenBasedPixelWidth: screenBasedPixelWidth,
        screenBasedPixelHeight: screenBasedPixelHeight,
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
      onProcessingSomething: (bool value) {
        onProcessingSomething.call(value);
      },
    ));
  } else if (currentStatus == "userLoggedIn") {
    onBody.call(
      StudentPortal(
        key: const ValueKey<int>(2),
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
            onError: (String value) {
              onError.call(value);
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
            onError: (String value) {
              onError.call(value);
            },
          );
        },
        onClassAttendance: (bool value) {
          onRequestType.call("Real");
          callClassAttendance(
            context: context,
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl.call(value);
            },
            processingSomething: value,
            onProcessingSomething: (bool value) {
              onProcessingSomething.call(value);
            },
            onError: (String value) {
              onError.call(value);
            },
          );
        },
        onPerformSignOut: (bool value) {
          performSignOut(
            context: context,
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl.call(value);
            },
            onError: (String value) {
              onError.call(value);
            },
          );
        },
        arguments: StudentPortalArguments(
          processingSomething: processingSomething,
          studentPortalDocument: studentPortalDocument,
          studentProfileAllViewDocument: studentProfileAllViewDocument,
          headlessWebView: headlessWebView,
          studentName: studentName,
          sessionDateTime: sessionDateTime,
          screenBasedPixelWidth: screenBasedPixelWidth,
          screenBasedPixelHeight: screenBasedPixelHeight,
        ),
        onProcessingSomething: (bool value) {
          onProcessingSomething.call(value);
        },
      ),
    );
  } else if (currentStatus == "originalVTOP") {
    onBody.call(
      FullWebView(
        key: const ValueKey<int>(3),
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
            onError: (String value) {
              onError.call(value);
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
            onError: (String value) {
              onError.call(value);
            },
          );
        },
        arguments: FullWebViewArguments(
          processingSomething: processingSomething,
          studentPortalDocument: studentPortalDocument,
          studentProfileAllViewDocument: studentProfileAllViewDocument,
          headlessWebView: headlessWebView,
          studentName: studentName,
          sessionDateTime: sessionDateTime,
          themeMode: themeMode,
          onThemeMode: (ThemeMode value) {
            onThemeMode?.call(value);
          },
          screenBasedPixelWidth: screenBasedPixelWidth,
          screenBasedPixelHeight: screenBasedPixelHeight,
        ),
        onPerformSignOut: (bool value) {
          performSignOut(
            context: context,
            headlessWebView: headlessWebView,
            onCurrentFullUrl: (String value) {
              onCurrentFullUrl.call(value);
            },
            onError: (String value) {
              onError.call(value);
            },
          );
        },
        onProcessingSomething: (bool value) {
          onProcessingSomething.call(value);
        },
      ),
    );
  }
}
