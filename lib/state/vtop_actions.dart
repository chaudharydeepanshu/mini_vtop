import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/state/user_login_state.dart';
import 'package:minivtop/state/vtop_controller_state.dart';
import 'package:minivtop/state/webview_state.dart';

import '../models/vtop_contoller_model.dart';
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
  VTOPActions(this.ref);

  final Ref ref;

  bool enableOfflineMode = false;

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

  VTOPPageStatus _studentAttendancePageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get studentAttendancePageStatus =>
      _studentAttendancePageStatus;

  VTOPPageStatus _studentTimeTablePageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get studentTimeTablePageStatus => _studentTimeTablePageStatus;

  VTOPPageStatus _forgotUserIDPageStatus = VTOPPageStatus.notProcessing;
  VTOPPageStatus get forgotUserIDPageStatus => _forgotUserIDPageStatus;

  late final HeadlessWebView readHeadlessWebViewProviderValue =
      ref.read(headlessWebViewProvider);

  late final UserLoginState readUserLoginStateProviderValue =
      ref.read(userLoginStateProvider);

  late final ConnectionStatusState readConnectionStatusStateProviderValue =
      ref.read(connectionStatusStateProvider);

  late final ErrorStatusState readErrorStatusStateProviderValue =
      ref.read(errorStatusStateProvider);

  late final VTOPControllerState readVTOPControllerStateProviderValue =
      ref.read(vtopControllerStateProvider);

  void updateOfflineModeStatus({required bool mode}) {
    enableOfflineMode = mode;
    notifyListeners();
  }

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

  void updateStudentAttendancePageStatus({required VTOPPageStatus status}) {
    _studentAttendancePageStatus = status;
    notifyListeners();
  }

  void updateStudentTimeTablePageStatus({required VTOPPageStatus status}) {
    _studentTimeTablePageStatus = status;
    notifyListeners();
  }

  void updateForgotUserIDPageStatus({required VTOPPageStatus status}) {
    _forgotUserIDPageStatus = status;
    notifyListeners();
  }

  void openLoginPageAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        _loginPageStatus = VTOPPageStatus.processing;
      },
      performAction: () async {
        await headlessWebView.webViewController
            ?.evaluateJavascript(source: "openPage();");
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {},
    );
  }

  void performCaptchaRefreshAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        readUserLoginStateProviderValue.updateCaptchaImage(bytes: null);
      },
      performAction: () async {
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {},
    );
  }

  void performSignOutAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        readUserLoginStateProviderValue.updateLoginStatus(
            loginStatus: LoginResponseStatus.loggedOut);
      },
      performAction: () async {
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
                               ajaxCall('processLogout',null,'page_outline');
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {
        //Todo: test this scenario.
      },
    );
  }

  void performSignInAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        readUserLoginStateProviderValue.updateLoginStatus(
            loginStatus: LoginResponseStatus.processing);
      },
      performAction: () async {
        String userID = readUserLoginStateProviderValue.userID;
        String password = readUserLoginStateProviderValue.password;
        String captcha = readUserLoginStateProviderValue.captcha;
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
        // document.getElementById('uname').value = '$userID';
        // document.getElementById('passwd').value = '$password';
        // document.getElementById('captchaCheck').value = '$captcha';
        // document.getElementById('captcha').click();
        
        data = "uname="+"$userID"+"&passwd="+`\${encodeURIComponent('$password')}`+"&captchaCheck="+"$captcha";
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {},
    );
  }

  void studentProfileAllViewAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        _studentProfilePageStatus = VTOPPageStatus.processing;
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            readErrorStatusStateProviderValue.update(
                status: ErrorStatus.noError));
      },
      performAction: () async {
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
    );
  }

  void studentGradeHistoryAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        _studentGradeHistoryPageStatus = VTOPPageStatus.processing;
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            readErrorStatusStateProviderValue.update(
                status: ErrorStatus.noError));
      },
      performAction: () async {
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
    );
  }

  void studentAttendanceAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        _studentAttendancePageStatus = VTOPPageStatus.processing;
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            readErrorStatusStateProviderValue.update(
                status: ErrorStatus.noError));
      },
      performAction: () async {
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
                               document.getElementById("ACD0042").click();
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
    );
  }

  void studentAttendanceViewAction({String? attendanceID}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        _studentAttendancePageStatus = VTOPPageStatus.processing;
      },
      performAction: () async {
        VTOPControllerModel vtopController =
            readVTOPControllerStateProviderValue.vtopController;
        String semesterSubId = attendanceID ?? vtopController.attendanceID;
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
        document.getElementById("semesterSubId").value = "$semesterSubId";
                               processStudentAttendance();
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
    );
  }

  void studentTimeTableAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        _studentTimeTablePageStatus = VTOPPageStatus.processing;
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            readErrorStatusStateProviderValue.update(
                status: ErrorStatus.noError));
      },
      performAction: () async {
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
                               document.getElementById("ACD0034").click();
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
    );
  }

  void studentTimeTableViewAction({String? timeTableID}) async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        _studentTimeTablePageStatus = VTOPPageStatus.processing;
      },
      performAction: () async {
        VTOPControllerModel vtopController =
            readVTOPControllerStateProviderValue.vtopController;
        String semesterSubId = timeTableID ?? vtopController.timeTableID;
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
        document.getElementById("semesterSubId").value = "$semesterSubId";
                               processViewTimeTable("$semesterSubId");
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {
        readHeadlessWebViewProviderValue.settingSomeVars();
        readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
        notifyListeners();
      },
    );
  }

  void forgotUserIDAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        _forgotUserIDPageStatus = VTOPPageStatus.processing;
      },
      performAction: () async {
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {},
    );
  }

  void forgotUserIDSearchAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        readUserLoginStateProviderValue.updateForgotUserIDSearchStatus(
            status: ForgotUserIDSearchResponseStatus.searching);
      },
      performAction: () async {
        String erpIDOrRegNo = readUserLoginStateProviderValue.erpIDOrRegNo;
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
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
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {},
    );
  }

  void forgotUserIDValidateAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {
        readUserLoginStateProviderValue.updateForgotUserIDValidateStatus(
            status: ForgotUserIDValidateResponseStatus.processing);
      },
      performAction: () async {
        String emailOTP = readUserLoginStateProviderValue.emailOTP;
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
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
      },
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {},
    );
  }

  void emptyAjaxAction() async {
    HeadlessInAppWebView headlessWebView =
        readHeadlessWebViewProviderValue.headlessWebView;

    _actionHandler(
      headlessWebView: headlessWebView,
      initialAction: () {},
      performAction: () async {
        await headlessWebView.webViewController?.evaluateJavascript(source: '''
                            \$.ajax({});
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
      },
      otherErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.webpageNotAvailable);
      },
      nullDocErrorAction: () {
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.nullDocBeforeAction);
      },
      notLoggedInScreenAction: () {},
    );
  }
}

void _actionHandler({
  required HeadlessInAppWebView headlessWebView,
  required Function() sessionTimeOutAction,
  required Function() performAction,
  required Function() initialAction,
  required Function() closedConnectionErrorAction,
  required Function() otherErrorAction,
  required Function() nullDocErrorAction,
  required Function() notLoggedInScreenAction,
}) async {
  // Perform initial action like setting status to processing.
  initialAction();

  if (headlessWebView.isRunning()) {
    // If true means then headless WebView is running.

    await headlessWebView.webViewController
        ?.evaluateJavascript(
            source: "new XMLSerializer().serializeToString(document);")
        .then((value) async {
      if (value != null) {
        if (value.contains("Web page not available")) {
          log('Web page not available.');
          if (value.contains("net::ERR_CONNECTION_CLOSED")) {
            log('net::ERR_CONNECTION_CLOSED');

            closedConnectionErrorAction();
          } else {
            log('Web page not available.');

            // errorSnackBar(
            //     context: rootScaffoldMessengerKey.currentState!.context,
            //     error: "sslError -> $sslError");
            // otherErrorAction();
            await FirebaseCrashlytics.instance.recordError(
                'Web page not available.', null,
                reason: 'a non-fatal error');
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

        if (!value.contains("(STUDENT)")) {
          // If true means then action can't be performed as this screen doesn't looks like logged in screen.
          log('Maybe the session is active but the user is probably not logged in.');

          notLoggedInScreenAction();
        }
      } else {
        // If true means then document is null.

        log('Document is null.');

        nullDocErrorAction();
        await FirebaseCrashlytics.instance.recordError(
            'Document is null.', null,
            reason: 'a non-fatal error');
      }
    });
  } else {
    log('HeadlessInAppWebView is not running.');
  }
}
