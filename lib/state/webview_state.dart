import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:mini_vtop/state/connection_state.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/user_login_state.dart';
import 'package:mini_vtop/state/vtop_actions.dart';

import 'package:mini_vtop/utils/captcha_parser.dart';

class HeadlessWebView extends ChangeNotifier {
  HeadlessWebView(this.read);

  final Reader read;

  late HeadlessInAppWebView _headlessWebView;
  HeadlessInAppWebView get headlessWebView => _headlessWebView;

  late InAppWebViewGroupOptions _options;
  String _url = "";
  String get url => _url;

  int _noOfHomePageBuilds = 0;

  late final UserLoginState readUserLoginStateProviderValue =
      read(userLoginStateProvider);

  late final ConnectionStatusState readConnectionStatusStateProviderValue =
      read(connectionStatusStateProvider);

  late final VTOPActions readVTOPActionsProviderValue =
      read(vtopActionsProvider);

  @override
  void dispose() {
    headlessWebView.dispose();
    super.dispose();
  }

  init() async {
    _options = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          useShouldInterceptAjaxRequest: true,
          useShouldInterceptFetchRequest: true,
        ),
        android: AndroidInAppWebViewOptions(
            // useHybridComposition: true,
            ),
        ios: IOSInAppWebViewOptions());

    _headlessWebView = HeadlessInAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.parse("https://vtop.vitbhopal.ac.in/vtop/")),
      initialOptions: _options,
      onWebViewCreated: (InAppWebViewController controller) {
        log('HeadlessInAppWebView created!');
      },
      onConsoleMessage:
          (InAppWebViewController controller, ConsoleMessage consoleMessage) {
        log('Console Message: ${consoleMessage.message}');
      },
      shouldInterceptAjaxRequest:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
        return ajaxRequest;
      },
      onAjaxReadyStateChange:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
        return AjaxRequestAction.PROCEED;
      },
      onAjaxProgress:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
        // print(ajaxRequest.url.toString());
        if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
            !(await controller.isLoading())) {
          if (ajaxRequest.url.toString() == "vtopLogin") {
            _vtopLoginAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() == "doRefreshCaptcha") {
            _doRefreshCaptchaAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() == "doLogin") {
            _vtopDoLoginAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() ==
              "studentsRecord/StudentProfileAllView") {
            _vtopStudentProfileAllViewAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() ==
              "examinations/examGradeView/StudentGradeHistory") {
            _vtopStudentGradeHistoryAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() == "forgotUserID") {
            _vtopForgotUserIDAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() ==
              "vtop/forgotUserID/validate") {
            _vtopForgotUserIDSearchAjaxRequest(ajaxRequest: ajaxRequest);
          } else if (ajaxRequest.url.toString() == "forgotLoginID") {
            _vtopForgotUserIDValidateAjaxRequest(ajaxRequest: ajaxRequest);
          } else {
            log("ajaxRequest.url:- ${ajaxRequest.url.toString()}");
          }
        }
        return AjaxRequestAction.PROCEED;
      },
      shouldInterceptFetchRequest:
          (InAppWebViewController controller, FetchRequest fetchRequest) async {
        return fetchRequest;
      },
      onLoadStart: (InAppWebViewController controller, Uri? url) async {
        log('onLoadStart $url');
        _url = url?.toString() ?? '';
      },
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        log('onLoadStop $url');
        _url = url?.toString() ?? '';
        _onLoadStopAction(url: url);
      },
    );

    runHeadlessInAppWebView();
  }

  resetControlVars() {
    _noOfHomePageBuilds = 0;
  }

  settingSomeVarsBeforeWebViewRestart({
    LoginResponseStatus? loginStatus,
    ConnectionStatus? connectionStatus,
    ForgotUserIDSearchResponseStatus? forgotUserIDSearchStatus,
    ForgotUserIDValidateResponseStatus? forgotUserIDValidateStatus,
    VTOPStatus? vtopStatus,
  }) {
    readConnectionStatusStateProviderValue.update(
        newStatus: connectionStatus ?? ConnectionStatus.connecting);
    readUserLoginStateProviderValue.updateLoginStatus(
        loginStatus: loginStatus ?? LoginResponseStatus.loggedOut);
    readUserLoginStateProviderValue.updateForgotUserIDSearchStatus(
        status: forgotUserIDSearchStatus ??
            ForgotUserIDSearchResponseStatus.notSearching);
    readUserLoginStateProviderValue.updateForgotUserIDValidateStatus(
        status: forgotUserIDValidateStatus ??
            ForgotUserIDValidateResponseStatus.notProcessing);
    readVTOPActionsProviderValue.updateVTOPStatus(
        status: vtopStatus ?? VTOPStatus.noStatus);
    readUserLoginStateProviderValue.updateCaptchaImage(bytes: null);
  }

  runHeadlessInAppWebView() async {
    resetControlVars();
    try {
      await headlessWebView.dispose();
    } on Exception catch (exception) {
      log(exception.toString());
    } catch (error) {
      log(error.toString());
    }
    await headlessWebView.run();
  }

  _vtopForgotUserIDValidateAjaxRequest(
      {required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            Document document = parse('$value');
            if (value.contains("Login ID is :")) {
              log("User ID found.");
              readUserLoginStateProviderValue.setUserIDFromForgotUserIDValidate(
                  forgotUserIDValidateDocument: document);
              readUserLoginStateProviderValue.updateForgotUserIDValidateStatus(
                  status: ForgotUserIDValidateResponseStatus.successful);
            } else if (value.contains("Invalid OTP. Please try again.")) {
              log("OTP is invalid.");
              readUserLoginStateProviderValue.updateForgotUserIDValidateStatus(
                  status: ForgotUserIDValidateResponseStatus.invalidOTP);
            } else if (value.contains("You are not authorized")) {
              log("You are not authorized.");
              readUserLoginStateProviderValue.updateForgotUserIDValidateStatus(
                  status: ForgotUserIDValidateResponseStatus.unknownResponse);
            } else {
              log("Unknown response");
              log(value.toString());
              settingSomeVarsBeforeWebViewRestart(
                  forgotUserIDValidateStatus:
                      ForgotUserIDValidateResponseStatus.unknownResponse);
              runHeadlessInAppWebView();
            }
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVarsBeforeWebViewRestart();
          runHeadlessInAppWebView();
        });
  }

  _vtopForgotUserIDSearchAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            Document document = parse('$value');
            // log(value);
            if (value.contains(
                "New OTP can be generated 10 minutes after last successful OTP was triggred")) {
              log("OTP is sent to email successfully");
              readUserLoginStateProviderValue.setOTPTriggerWait(
                  forgotUserIDSearchDocument: document);
              readUserLoginStateProviderValue.updateForgotUserIDSearchStatus(
                  status: ForgotUserIDSearchResponseStatus.otpTriggerWait);
            } else if (value.contains("OTP has been sent to your email")) {
              log("OTP is sent to email successfully");
              readUserLoginStateProviderValue.updateForgotUserIDSearchStatus(
                  status: ForgotUserIDSearchResponseStatus.found);
            } else if (value.contains("Invalid User id")) {
              log("User id is invalid");
              readUserLoginStateProviderValue.updateForgotUserIDSearchStatus(
                  status: ForgotUserIDSearchResponseStatus.notFound);
            } else {
              log("Unknown response");
              // log(value.toString());
              settingSomeVarsBeforeWebViewRestart(
                  forgotUserIDSearchStatus:
                      ForgotUserIDSearchResponseStatus.unknownResponse);
              runHeadlessInAppWebView();
            }
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVarsBeforeWebViewRestart();
          runHeadlessInAppWebView();
        });
  }

  _vtopForgotUserIDAjaxRequest({required AjaxRequest ajaxRequest}) async {
    readVTOPActionsProviderValue.updateVTOPStatus(
        status: VTOPStatus.forgotUserIDPage);
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            // Document document = parse('$value');
            if (value.contains("V-TOP Forgot UserID")) {
              log("Forgot UserID page loaded successfully");
              readVTOPActionsProviderValue.updateForgotUserIDPageStatus(
                  status: VTOPPageStatus.loaded);
            } else {
              log("Unknown error");
              readVTOPActionsProviderValue.updateForgotUserIDPageStatus(
                  status: VTOPPageStatus.unknownResponse);
              settingSomeVarsBeforeWebViewRestart();
              runHeadlessInAppWebView();
            }
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVarsBeforeWebViewRestart();
          runHeadlessInAppWebView();
        });
  }

  _doRefreshCaptchaAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) async {
            Document document = parse('${ajaxRequest.responseText}');
            String? imageSrc = document
                .querySelector('img[alt="vtopCaptcha"]')
                ?.attributes["src"];
            // log(imageSrc.toString());
            if (imageSrc != null) {
              String uri = imageSrc;
              String base64String = uri.split(', ').last;
              Uint8List bytes = base64.decode(base64String);
              String solvedCaptcha = await getSolvedCaptcha(imageBytes: bytes);
              readUserLoginStateProviderValue.updateCaptchaImage(bytes: bytes);
              readUserLoginStateProviderValue.setAutoCaptcha(
                  autoCaptcha: solvedCaptcha);
            }
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVarsBeforeWebViewRestart();
          runHeadlessInAppWebView();
        });
  }

  _vtopDoLoginAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            // Document document = parse('$value');
            if (value.contains(
                "${readUserLoginStateProviderValue.userID}(STUDENT)")) {
              log("User Id ${readUserLoginStateProviderValue.userID} logged in.");
              readUserLoginStateProviderValue.updateLoginStatus(
                  loginStatus: LoginResponseStatus.loggedIn);
              readVTOPActionsProviderValue.updateVTOPStatus(
                  status: VTOPStatus.sessionActive);
            } else if (value.contains("User Id Not available")) {
              log("User Id ${readUserLoginStateProviderValue.userID} is not available.");
              readUserLoginStateProviderValue.updateLoginStatus(
                  loginStatus: LoginResponseStatus.wrongUserId);
            } else if (value.contains("Invalid User Id / Password")) {
              log("Password ${readUserLoginStateProviderValue.password} is wrong.");
              readUserLoginStateProviderValue.updateLoginStatus(
                  loginStatus: LoginResponseStatus.wrongPassword);
            } else if (value.contains("Invalid Captcha")) {
              log("Captcha is invalid.");
              readUserLoginStateProviderValue.updateLoginStatus(
                  loginStatus: LoginResponseStatus.wrongCaptcha);
            } else if (value.contains(
                "Number of Maximum Fail Attempts Reached. use Forgot Password")) {
              log("Maximum Fail Attempts Reached. use Forgot Password");
              readUserLoginStateProviderValue.updateLoginStatus(
                  loginStatus: LoginResponseStatus.maxAttemptsError);
            } else {
              log("Unknown error.");
              readUserLoginStateProviderValue.updateLoginStatus(
                  loginStatus: LoginResponseStatus.unknownResponse);
            }
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVarsBeforeWebViewRestart();
          runHeadlessInAppWebView();
        });
  }

  _vtopStudentProfileAllViewAjaxRequest(
      {required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            Document document = parse('$value');
            read(vtopDataProvider)
                .setStudentProfile(studentProfileViewDocument: document);

            readVTOPActionsProviderValue.updateStudentProfilePageStatus(
                status: VTOPPageStatus.loaded);
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVarsBeforeWebViewRestart();
          runHeadlessInAppWebView();
        });
  }

  _vtopStudentGradeHistoryAjaxRequest(
      {required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) {
            Document document = parse('$value');
            read(vtopDataProvider)
                .setStudentAcademics(studentGradeHistoryDocument: document);

            readVTOPActionsProviderValue.updateStudentGradeHistoryPageStatus(
                status: VTOPPageStatus.loaded);
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVarsBeforeWebViewRestart();
          runHeadlessInAppWebView();
        });
  }

  _vtopLoginAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          readVTOPActionsProviderValue.updateLoginPageStatus(
              status: VTOPPageStatus.loaded);
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.studentLoginPage);
          await headlessWebView.webViewController
              .evaluateJavascript(
                  source: "new XMLSerializer().serializeToString(document);")
              .then((value) async {
            Document document = parse('${ajaxRequest.responseText}');
            String? imageSrc = document
                .querySelector('img[alt="vtopCaptcha"]')
                ?.attributes["src"];
            if (imageSrc != null) {
              String uri = imageSrc;
              String base64String = uri.split(', ').last;
              Uint8List bytes = base64.decode(base64String);
              String solvedCaptcha = await getSolvedCaptcha(imageBytes: bytes);
              readUserLoginStateProviderValue.updateCaptchaImage(bytes: bytes);
              readUserLoginStateProviderValue.setAutoCaptcha(
                  autoCaptcha: solvedCaptcha);
            }
          });
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVarsBeforeWebViewRestart();
          runHeadlessInAppWebView();
        });
  }

  _onLoadStopAction({required Uri? url}) async {
    _onLoadStopHandler(
      url: url,
      headlessWebView: headlessWebView,
      loginAction: () async {
        _noOfHomePageBuilds++;
        if (_noOfHomePageBuilds == 1) {
          // This condition is extremely crucial as it stops the endless loop of VTOP loading.
          // VTOP send onLoadStop request many times.
          // And when we click login on the new requests then the old requests login get a session time out.
          // And then the session time out request will call restart for WebView which will lead to an endless loop.
          // readVTOPActionsProviderValue.openLoginPageAction();
          readConnectionStatusStateProviderValue.update(
              newStatus: ConnectionStatus.connected);
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.homepage);
        }
      },
      alreadyLoggedInAction: () {
        readConnectionStatusStateProviderValue.update(
            newStatus: ConnectionStatus.connected);
        readVTOPActionsProviderValue.updateVTOPStatus(
            status: VTOPStatus.sessionActive);
        readUserLoginStateProviderValue.updateLoginStatus(
            loginStatus: LoginResponseStatus.loggedIn);
      },
      sessionTimeOutAction: () {
        log("Session timed out.");
        readVTOPActionsProviderValue.updateVTOPStatus(
            status: VTOPStatus.sessionTimedOut);
        settingSomeVarsBeforeWebViewRestart();
        runHeadlessInAppWebView();
      },
    );
  }
}

_onLoadStopHandler({
  required Uri? url,
  required HeadlessInAppWebView headlessWebView,
  required Function() loginAction,
  required Function() alreadyLoggedInAction,
  required Function() sessionTimeOutAction,
}) async {
  await headlessWebView.webViewController
      .evaluateJavascript(
          source: "new XMLSerializer().serializeToString(document);")
      .then((value) async {
    String initialVTOPHtml =
        '<html xmlns="http://www.w3.org/1999/xhtml"><head></head><body></body></html>';

    if (value.contains(
        "You are logged out due to inactivity for more than 15 minutes")) {
      /// If true means session timed out.

      sessionTimeOutAction();
    } else if (url.toString() ==
            "https://vtop.vitbhopal.ac.in/vtop/initialProcess" &&
        await headlessWebView.webViewController.getProgress() == 100 &&
        !(await headlessWebView.webViewController.isLoading()) &&
        value != initialVTOPHtml &&
        value != null &&
        value.contains("V-TOP for Employee and Students")) {
      /// If true means VTOP is loaded.

      loginAction();
    } else if (url.toString() == "https://vtop.vitbhopal.ac.in/vtop/" &&
        await headlessWebView.webViewController.getProgress() == 100 &&
        !(await headlessWebView.webViewController.isLoading()) &&
        value.contains("(STUDENT)")) {
      /// If true means VTOP is already logged in and homepage is loaded.

      alreadyLoggedInAction();
    }
  });
}

_ajaxRequestCommonHandler(
    {required AjaxRequest ajaxRequest,
    required Function() ajaxRequestStatus200Action,
    required Function() ajaxRequestStatus232Action}) async {
  if (ajaxRequest.status == 200) {
    /// ajaxRequest.status == 200 means a successful operation without any issues.

    log("ajaxRequest.status: 200 encountered");
    ajaxRequestStatus200Action();
  } else if (ajaxRequest.status == 231) {
    /// ajaxRequest.status == 231 loads the homepage for VTOP. Homepage not login page.
    /// If user logged in then logged in homepage for VTOP is loaded.

    log("ajaxRequest.status: 231 encountered");
  } else if (ajaxRequest.status == 232) {
    /// ajaxRequest.status == 232 means the Session Timed out.
    /// The ajaxRequest.responseText should contain "You are logged out due to inactivity for more than 15 minutes"
    /// ajaxRequest.responseText!.contains("You are logged out due to inactivity for more than 15 minutes") should be true.

    log("ajaxRequest.status: 232 encountered");
    ajaxRequestStatus232Action();
  } else if (ajaxRequest.status == 233) {
    /// ajaxRequest.status == 233 executes same operation as ajaxRequest.status == 200.
    /// But is still an error request.
    /// Todo: Find the situation in which this status is encountered and then handle that suitably.

    log("ajaxRequest.status: 233 encountered");
  } else {
    /// Any other ajaxRequest.status executes same operation as ajaxRequest.status == 200.

    log("ajaxRequest.status: ${ajaxRequest.status} encountered");
  }
}
