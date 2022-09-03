import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/user_login_state.dart';
import 'package:mini_vtop/state/webview_state.dart';

import 'connection_state.dart';
import 'error_state.dart';

enum VTOPStatus {
  noStatus,
  homepage,
  forgotUserIDPage,
  studentLoginPage,
  sessionActive,
  sessionTimedOut,
  // error,
}

enum VTOPPageStatus {
  notProcessing,
  processing,
  loaded,
  // unknownResponse
}

class VTOPActions extends ChangeNotifier {
  VTOPActions(this.read);

  final Reader read;

  // Keeps track of VTOP main pages status.
  VTOPStatus _vtopStatus = VTOPStatus.sessionTimedOut;
  VTOPStatus get vtopStatus => _vtopStatus;

  VTOPPageStatus _loginPageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get loginPageStatus => _loginPageStatus;

  VTOPPageStatus _studentProfilePageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get studentProfilePageStatus => _studentProfilePageStatus;

  VTOPPageStatus _studentGradeHistoryPageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get studentGradeHistoryPageStatus =>
      _studentGradeHistoryPageStatus;

  VTOPPageStatus _forgotUserIDPageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get forgotUserIDPageStatus => _forgotUserIDPageStatus;

  late final HeadlessWebView readHeadlessWebViewProviderValue =
      read(headlessWebViewProvider);

  late final UserLoginState readUserLoginStateProviderValue =
      read(userLoginStateProvider);

  late final ConnectionStatusState readConnectionStatusStateProviderValue =
      read(connectionStatusStateProvider);

  late final ErrorStatusState readErrorStatusStateProviderValue =
      read(errorStatusStateProvider);

  void updateVTOPStatus({required VTOPStatus status}) {
    _vtopStatus = status;
    notifyListeners();
  }

  void updateLoginPageStatus({required VTOPPageStatus status}) {
    _loginPageStatus = status;
    notifyListeners();
  }

  void updateStudentProfilePageStatus({required VTOPPageStatus status}) {
    _studentProfilePageStatus = status;
    notifyListeners();
  }

  void updateStudentGradeHistoryPageStatus({required VTOPPageStatus status}) {
    _studentGradeHistoryPageStatus = status;
    notifyListeners();
  }

  void updateForgotUserIDPageStatus({required VTOPPageStatus status}) {
    _forgotUserIDPageStatus = status;
    notifyListeners();
  }

  void openLoginPageAction({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      context: context,
      headlessWebView: headlessWebView,
      initialAction: () {
        _loginPageStatus = VTOPPageStatus.processing;
      },
      performAction: () async {
        await headlessWebView.webViewController
            .evaluateJavascript(source: "openPage();");
      },
      sessionTimeOutAction: () {
        _vtopStatus = VTOPStatus.sessionTimedOut;
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
      closedConnectionErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.connectionClosedError);
        notifyListeners();
      },
    );
  }

  void performCaptchaRefreshAction({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      context: context,
      headlessWebView: headlessWebView,
      initialAction: () {
        readUserLoginStateProviderValue.updateCaptchaImage(bytes: null);
      },
      performAction: () async {
        await headlessWebView.webViewController.evaluateJavascript(source: '''
                               doRefreshCaptcha();
                                ''');
      },
      sessionTimeOutAction: () {
        _vtopStatus = VTOPStatus.sessionTimedOut;
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
      closedConnectionErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.connectionClosedError);
        notifyListeners();
      },
    );
  }

  void performSignInAction({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      context: context,
      headlessWebView: headlessWebView,
      initialAction: () {
        readUserLoginStateProviderValue.updateLoginStatus(
            loginStatus: LoginResponseStatus.processing);
      },
      performAction: () async {
        String userID = readUserLoginStateProviderValue.userID;
        String password = readUserLoginStateProviderValue.password;
        String captcha = readUserLoginStateProviderValue.captcha;
        await headlessWebView.webViewController.evaluateJavascript(source: '''
        // document.getElementById('uname').value = '$userID';
        // document.getElementById('passwd').value = '$password';
        // document.getElementById('captchaCheck').value = '$captcha';
        // document.getElementById('captcha').click();
        
        data = "uname="+"$userID"+"&passwd="+`\${encodeURIComponent('$password')}`+"&captchaCheck="+"$captcha";
          console.log(data);
        ajaxCall('doLogin',data,'page_outline');
                                ''');
      },
      sessionTimeOutAction: () {
        _vtopStatus = VTOPStatus.sessionTimedOut;
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
      closedConnectionErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.connectionClosedError);
        notifyListeners();
      },
    );
  }

  void studentProfileAllViewAction({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      context: context,
      headlessWebView: headlessWebView,
      initialAction: () {
        _studentProfilePageStatus = VTOPPageStatus.processing;
      },
      performAction: () async {
        await headlessWebView.webViewController.evaluateJavascript(source: '''
                               document.getElementById("STA002").click();
                                ''');
      },
      sessionTimeOutAction: () {
        _vtopStatus = VTOPStatus.sessionTimedOut;
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
      closedConnectionErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.connectionClosedError);
        notifyListeners();
      },
    );
  }

  void studentGradeHistoryAction({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      context: context,
      headlessWebView: headlessWebView,
      initialAction: () {
        _studentGradeHistoryPageStatus = VTOPPageStatus.processing;
      },
      performAction: () async {
        await headlessWebView.webViewController.evaluateJavascript(source: '''
                               document.getElementById("EXM0023").click();
                                ''');
      },
      sessionTimeOutAction: () {
        _vtopStatus = VTOPStatus.sessionTimedOut;
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
      closedConnectionErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.connectionClosedError);
        notifyListeners();
      },
    );
  }

  void forgotUserIDAction({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      context: context,
      headlessWebView: headlessWebView,
      initialAction: () {
        _forgotUserIDPageStatus = VTOPPageStatus.processing;
      },
      performAction: () async {
        await headlessWebView.webViewController.evaluateJavascript(source: '''
                               forgotUserID();
                                ''');
      },
      sessionTimeOutAction: () {
        _vtopStatus = VTOPStatus.sessionTimedOut;
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
      closedConnectionErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.connectionClosedError);
        notifyListeners();
      },
    );
  }

  void forgotUserIDSearchAction({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      context: context,
      headlessWebView: headlessWebView,
      initialAction: () {
        readUserLoginStateProviderValue.updateForgotUserIDSearchStatus(
            status: ForgotUserIDSearchResponseStatus.searching);
      },
      performAction: () async {
        String erpIDOrRegNo = readUserLoginStateProviderValue.erpIDOrRegNo;
        await headlessWebView.webViewController.evaluateJavascript(source: '''
            document.getElementById("userId").value = '$erpIDOrRegNo';
         document.getElementById("btnSubmit").click();
                                ''');
      },
      sessionTimeOutAction: () {
        _vtopStatus = VTOPStatus.sessionTimedOut;
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
      closedConnectionErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.connectionClosedError);
        notifyListeners();
      },
    );
  }

  void forgotUserIDValidateAction({required BuildContext context}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      context: context,
      headlessWebView: headlessWebView,
      initialAction: () {
        readUserLoginStateProviderValue.updateForgotUserIDValidateStatus(
            status: ForgotUserIDValidateResponseStatus.processing);
      },
      performAction: () async {
        String emailOTP = readUserLoginStateProviderValue.emailOTP;
        await headlessWebView.webViewController.evaluateJavascript(source: '''
            document.getElementById("otp").value = '$emailOTP';
         document.getElementById("btnValidate").click();
                                ''');
      },
      sessionTimeOutAction: () {
        _vtopStatus = VTOPStatus.sessionTimedOut;
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
      closedConnectionErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.connectionClosedError);
        notifyListeners();
      },
    );
  }
}

void _actionHandler({
  required BuildContext context,
  required HeadlessInAppWebView headlessWebView,
  required Function() sessionTimeOutAction,
  required Function() performAction,
  required Function() initialAction,
  required Function() closedConnectionErrorAction,
}) async {
  // Perform initial action like setting status to processing.
  initialAction();

  if (headlessWebView.isRunning()) {
    // If true means then headless WebView is running.

    await headlessWebView.webViewController
        .evaluateJavascript(
            source: "new XMLSerializer().serializeToString(document);")
        .then((value) async {
      if (value != null) {
        if (value.contains("Web page not available")) {
          log('Web page not available.');
          if (value.contains("net::ERR_CONNECTION_CLOSED")) {
            log('net::ERR_CONNECTION_CLOSED');

            closedConnectionErrorAction();
          } else {
            // connectionErrorAction();
          }
        } else if (value.contains(
            "You are logged out due to inactivity for more than 15 minutes")) {
          log('Session timed out.');

          sessionTimeOutAction();
        } else {
          // If true means then action can be performed.

          log('Performing action.');
          performAction();
        }
      } else {
        // If true means then action can be performed.

        log('Document is null.');
      }
    });
  } else {
    log('HeadlessInAppWebView is not running.');
  }
}
