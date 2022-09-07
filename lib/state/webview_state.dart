import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import '../ui/components/custom_snack_bar.dart';
import 'error_state.dart';

class HeadlessWebView extends ChangeNotifier {
  HeadlessWebView(this.read);

  final Reader read;

  late HeadlessInAppWebView _headlessWebView;
  HeadlessInAppWebView get headlessWebView => _headlessWebView;

  late InAppWebViewGroupOptions _options;

  final String _initialUrl = "http://182.73.197.23/vtop/";
  // "https://self-signed.badssl.com/";
  // "https://vtop.vitbhopal.ac.in/vtop/";

  String _url = "";
  String get url => _url;

  late final UserLoginState readUserLoginStateProviderValue =
      read(userLoginStateProvider);

  late final ConnectionStatusState readConnectionStatusStateProviderValue =
      read(connectionStatusStateProvider);

  late final VTOPActions readVTOPActionsProviderValue =
      read(vtopActionsProvider);

  late final ErrorStatusState readErrorStatusStateProviderValue =
      read(errorStatusStateProvider);

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
      initialUrlRequest: URLRequest(url: Uri.parse(_initialUrl)),
      initialOptions: _options,
      onWebViewCreated: (InAppWebViewController controller) {
        _url = _initialUrl;
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
          } else if (ajaxRequest.url.toString() == "processLogout") {
            _vtopProcessLogoutAjaxRequest(ajaxRequest: ajaxRequest);
          } else {
            log("ajaxRequest.url:- ${ajaxRequest.url.toString()}");
          }
        }
        return AjaxRequestAction.PROCEED;
      },
      shouldOverrideUrlLoading: (InAppWebViewController controller,
          NavigationAction navigationAction) async {
        _shouldOverrideUrlLoadingHandler(
            controller: controller,
            navigationAction: navigationAction,
            redirectFromUrl: url,
            initialUrl: _initialUrl);
        return NavigationActionPolicy.ALLOW;
      },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        // SslError? sslError = challenge.protectionSpace.sslError;
        // if (sslError != null &&
        //     (sslError.iosError != null || sslError.androidError != null)) {
        //   if (Platform.isIOS && sslError.iosError == IOSSslError.UNSPECIFIED) {
        //     return ServerTrustAuthResponse(
        //         action: ServerTrustAuthResponseAction.PROCEED);
        //   } else {
        //     log("SSL Error occurred: $sslError.");
        //     readErrorStatusStateProviderValue.update(
        //         status: ErrorStatus.sslError);
        // await FirebaseCrashlytics.instance.recordError(
        //     "sslError: $sslError", null,
        //     reason: 'a non-fatal error');
        //     return ServerTrustAuthResponse(
        //         action: ServerTrustAuthResponseAction.CANCEL);
        //   }
        // } else {
        //   return ServerTrustAuthResponse(
        //       action: ServerTrustAuthResponseAction.PROCEED);
        // }
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      shouldInterceptFetchRequest:
          (InAppWebViewController controller, FetchRequest fetchRequest) async {
        log('shouldInterceptFetchRequest $url');
        return fetchRequest;
      },
      onLoadStart: (InAppWebViewController controller, Uri? url) async {
        log('onLoadStart $url');
        _url = url?.toString() ?? '';
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        // log('progress $progress');
      },
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        // log('onLoadStop $url');
        _url = url?.toString() ?? '';
        _onLoadStopAction(url: url);
      },
      onLoadError: (InAppWebViewController controller, Uri? url, int code,
          String message) async {
        log("onLoadError -> url: $url, errorCode:$code, message:$message");
        readErrorStatusStateProviderValue.onLoadErrorHandler(
            url: url, code: code, message: message);
      },
      onLoadHttpError: (InAppWebViewController controller, Uri? url, int code,
          String message) async {
        log("onLoadHttpError -> url: $url, errorCode:$code, message:$message");
        readErrorStatusStateProviderValue.update(
            status: ErrorStatus.unknownError);
        await FirebaseCrashlytics.instance.recordError(
            "onLoadHttpError -> url: $url, errorCode:$code, message:$message",
            null,
            reason: 'a non-fatal error');
      },
    );

    runHeadlessInAppWebView();
  }

  settingSomeVars({
    LoginResponseStatus? loginStatus,
    VTOPPageStatus? loginPageStatus,
    VTOPPageStatus? studentProfilePageStatus,
    VTOPPageStatus? studentGradeHistoryPageStatus,
    ForgotUserIDSearchResponseStatus? forgotUserIDSearchStatus,
    ForgotUserIDValidateResponseStatus? forgotUserIDValidateStatus,
  }) {
    readUserLoginStateProviderValue.updateLoginStatus(
        loginStatus: loginStatus ?? LoginResponseStatus.loggedOut);
    readVTOPActionsProviderValue.updateLoginPageStatus(
        status: loginPageStatus ?? VTOPPageStatus.notProcessing);
    readVTOPActionsProviderValue.updateStudentProfilePageStatus(
        status: studentProfilePageStatus ?? VTOPPageStatus.notProcessing);
    readVTOPActionsProviderValue.updateStudentGradeHistoryPageStatus(
        status: studentGradeHistoryPageStatus ?? VTOPPageStatus.notProcessing);
    readUserLoginStateProviderValue.updateForgotUserIDSearchStatus(
        status: forgotUserIDSearchStatus ??
            ForgotUserIDSearchResponseStatus.notSearching);
    readUserLoginStateProviderValue.updateForgotUserIDValidateStatus(
        status: forgotUserIDValidateStatus ??
            ForgotUserIDValidateResponseStatus.notProcessing);
  }

  settingSomeVarsBeforeWebViewRestart() {
    readUserLoginStateProviderValue.updateCaptchaImage(bytes: null);
    readConnectionStatusStateProviderValue.update(
        status: ConnectionStatus.connecting);
    readVTOPActionsProviderValue.updateVTOPStatus(status: VTOPStatus.noStatus);
    readErrorStatusStateProviderValue.update(status: ErrorStatus.noError);
  }

  runHeadlessInAppWebView() async {
    try {
      await headlessWebView.dispose();
    } on Exception catch (exception) {
      log(exception.toString());
    } catch (error) {
      log(error.toString());
    }
    settingSomeVarsBeforeWebViewRestart();
    await headlessWebView.run();
  }

  _vtopProcessLogoutAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          if (readUserLoginStateProviderValue.loginResponseStatus ==
              LoginResponseStatus.processing) {
            log("Accepted ajaxRequest callback as till now no action was taken for logout action.");
            await headlessWebView.webViewController
                .evaluateJavascript(
                    source: "new XMLSerializer().serializeToString(document);")
                .then((value) async {
              if (value.contains("You have been successfully logged out")) {
                log("User is logged out successfully.");
                readUserLoginStateProviderValue.updateLoginStatus(
                    loginStatus: LoginResponseStatus.loggedOut);
              } else {
                log("Unknown response");
                readErrorStatusStateProviderValue.update(
                    status: ErrorStatus.vtopUnknownResponsesError);
                await FirebaseCrashlytics.instance.recordError(
                    "Unknown response _vtopProcessLogoutAjaxRequest", null,
                    reason: 'a non-fatal error');
              }
            });
          } else {
            log("Rejected ajaxRequest callback as till now action was already taken for forgotUserID Validate action.");
          }
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVars();
          runHeadlessInAppWebView();
        },
        ajaxRequestOtherStatusAction: () {
          log("Error occurred.");
          readErrorStatusStateProviderValue.update(
              status: ErrorStatus.vtopError);
        });
  }

  _vtopForgotUserIDValidateAjaxRequest(
      {required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          if (readUserLoginStateProviderValue.forgotUserIDValidateStatus ==
              ForgotUserIDValidateResponseStatus.processing) {
            log("Accepted ajaxRequest callback as till now no action was taken for forgotUserID Validate action.");
            await headlessWebView.webViewController
                .evaluateJavascript(
                    source: "new XMLSerializer().serializeToString(document);")
                .then((value) async {
              Document document = parse('$value');
              if (value.contains("Login ID is :")) {
                log("User ID found.");
                readUserLoginStateProviderValue
                    .setUserIDFromForgotUserIDValidate(
                        forgotUserIDValidateDocument: document);
                readUserLoginStateProviderValue
                    .updateForgotUserIDValidateStatus(
                        status: ForgotUserIDValidateResponseStatus.successful);
              } else if (value.contains("Invalid OTP. Please try again.")) {
                log("OTP is invalid.");
                readUserLoginStateProviderValue
                    .updateForgotUserIDValidateStatus(
                        status: ForgotUserIDValidateResponseStatus.invalidOTP);
              } else if (value.contains("You are not authorized")) {
                log("You are not authorized.");
                readUserLoginStateProviderValue
                    .updateForgotUserIDValidateStatus(
                        status:
                            ForgotUserIDValidateResponseStatus.notAuthorized);
              } else {
                log("Unknown response");
                readErrorStatusStateProviderValue.update(
                    status: ErrorStatus.vtopUnknownResponsesError);
                await FirebaseCrashlytics.instance.recordError(
                    "Unknown response _vtopForgotUserIDValidateAjaxRequest",
                    null,
                    reason: 'a non-fatal error');
              }
            });
          } else {
            log("Rejected ajaxRequest callback as till now action was already taken for forgotUserID Validate action.");
          }
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVars();
          runHeadlessInAppWebView();
        },
        ajaxRequestOtherStatusAction: () {
          log("Error occurred.");
          readErrorStatusStateProviderValue.update(
              status: ErrorStatus.vtopError);
        });
  }

  _vtopForgotUserIDSearchAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          if (readUserLoginStateProviderValue.forgotUserIDSearchStatus ==
              ForgotUserIDSearchResponseStatus.searching) {
            log("Accepted ajaxRequest callback as till now no action was taken for forgotUserID Search action.");
            await headlessWebView.webViewController
                .evaluateJavascript(
                    source: "new XMLSerializer().serializeToString(document);")
                .then((value) async {
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
                log("Unknown response error.");
                readErrorStatusStateProviderValue.update(
                    status: ErrorStatus.vtopUnknownResponsesError);
                await FirebaseCrashlytics.instance.recordError(
                    "Unknown response _vtopForgotUserIDSearchAjaxRequest", null,
                    reason: 'a non-fatal error');
              }
            });
          } else {
            log("Rejected ajaxRequest callback as till now action was already taken for forgotUserID Search action.");
          }
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVars();
          runHeadlessInAppWebView();
        },
        ajaxRequestOtherStatusAction: () {
          log("Error occurred.");
          readErrorStatusStateProviderValue.update(
              status: ErrorStatus.vtopError);
        });
  }

  _vtopForgotUserIDAjaxRequest({required AjaxRequest ajaxRequest}) async {
    readVTOPActionsProviderValue.updateVTOPStatus(
        status: VTOPStatus.forgotUserIDPage);
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          if (readVTOPActionsProviderValue.forgotUserIDPageStatus ==
              VTOPPageStatus.processing) {
            log("Accepted ajaxRequest callback as till now no action was taken for loaded ForgotUserID page.");
            await headlessWebView.webViewController
                .evaluateJavascript(
                    source: "new XMLSerializer().serializeToString(document);")
                .then((value) async {
              // Document document = parse('$value');
              if (value.contains("V-TOP Forgot UserID")) {
                log("Forgot UserID page loaded successfully");
                readVTOPActionsProviderValue.updateForgotUserIDPageStatus(
                    status: VTOPPageStatus.loaded);
              } else {
                log("Unknown response error.");
                readErrorStatusStateProviderValue.update(
                    status: ErrorStatus.vtopUnknownResponsesError);
                await FirebaseCrashlytics.instance.recordError(
                    "Unknown response _vtopForgotUserIDAjaxRequest", null,
                    reason: 'a non-fatal error');
              }
            });
          } else {
            log("Rejected ajaxRequest callback as till now action was already taken for loaded ForgotUserID page.");
          }
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVars();
          runHeadlessInAppWebView();
        },
        ajaxRequestOtherStatusAction: () {
          log("Error occurred.");
          readErrorStatusStateProviderValue.update(
              status: ErrorStatus.vtopError);
        });
  }

  _doRefreshCaptchaAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          if (readUserLoginStateProviderValue.captchaImage == null) {
            log("Accepted ajaxRequest callback as till now no action was taken for captcha refresh.");
            readUserLoginStateProviderValue.updateCaptchaImage(bytes: null);
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
                String solvedCaptcha =
                    await getSolvedCaptcha(imageBytes: bytes);
                readUserLoginStateProviderValue.updateCaptchaImage(
                    bytes: bytes);
                readUserLoginStateProviderValue.setAutoCaptcha(
                    autoCaptcha: solvedCaptcha);
              } else {
                await FirebaseCrashlytics.instance.recordError(
                    "Unknown response _doRefreshCaptchaAjaxRequest", null,
                    reason: 'a non-fatal error');
              }
            });
          } else {
            log("Rejected ajaxRequest callback as till now action was already taken for captcha refresh.");
          }
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVars();
          runHeadlessInAppWebView();
        },
        ajaxRequestOtherStatusAction: () {
          log("Error occurred.");
          readErrorStatusStateProviderValue.update(
              status: ErrorStatus.vtopError);
        });
  }

  _vtopDoLoginAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          if (readUserLoginStateProviderValue.loginResponseStatus ==
              LoginResponseStatus.processing) {
            log("Accepted ajaxRequest callback as till now no action was taken for login attempt.");
            await headlessWebView.webViewController
                .evaluateJavascript(
                    source: "new XMLSerializer().serializeToString(document);")
                .then((value) async {
              // Document document = parse('$value');
              if (value.contains("(STUDENT)")) {
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
                log("Unknown response error.");
                readErrorStatusStateProviderValue.update(
                    status: ErrorStatus.vtopUnknownResponsesError);
                readVTOPActionsProviderValue.updateLoginPageStatus(
                    status: VTOPPageStatus.notProcessing);
                await FirebaseCrashlytics.instance.recordError(
                    "Unknown response _vtopDoLoginAjaxRequest", null,
                    reason: 'a non-fatal error');
              }
            });
          } else {
            log("Rejected ajaxRequest callback as till now action was already taken for login attempt.");
          }
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVars();
          runHeadlessInAppWebView();
        },
        ajaxRequestOtherStatusAction: () {
          log("Error occurred.");
          readErrorStatusStateProviderValue.update(
              status: ErrorStatus.vtopError);
        });
  }

  _vtopStudentProfileAllViewAjaxRequest(
      {required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          if (readVTOPActionsProviderValue.studentProfilePageStatus ==
              VTOPPageStatus.processing) {
            log("Accepted ajaxRequest callback as till now no action was taken for loaded StudentProfileAllView.");
            await headlessWebView.webViewController
                .evaluateJavascript(
                    source: "new XMLSerializer().serializeToString(document);")
                .then((value) {
              read(vtopDataProvider)
                  .setStudentProfile(studentProfileViewDocument: value);

              readVTOPActionsProviderValue.updateStudentProfilePageStatus(
                  status: VTOPPageStatus.loaded);
            });
          } else {
            log("Rejected ajaxRequest callback as till now action was already taken for loaded StudentProfileAllView.");
          }
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVars();
          runHeadlessInAppWebView();
        },
        ajaxRequestOtherStatusAction: () {
          log("Error occurred.");
          readErrorStatusStateProviderValue.update(
              status: ErrorStatus.vtopError);
        });
  }

  _vtopStudentGradeHistoryAjaxRequest(
      {required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          if (readVTOPActionsProviderValue.studentGradeHistoryPageStatus ==
              VTOPPageStatus.processing) {
            log("Accepted ajaxRequest callback as till now no action was taken for loaded GradeHistory.");
            await headlessWebView.webViewController
                .evaluateJavascript(
                    source: "new XMLSerializer().serializeToString(document);")
                .then((value) {
              read(vtopDataProvider)
                  .setStudentAcademics(studentGradeHistoryDocument: value);
              readVTOPActionsProviderValue.updateStudentGradeHistoryPageStatus(
                  status: VTOPPageStatus.loaded);
            });
          } else {
            log("Rejected ajaxRequest callback as till now action was already taken for loaded GradeHistory.");
          }
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVars();
          runHeadlessInAppWebView();
        },
        ajaxRequestOtherStatusAction: () {
          log("Error occurred.");
          readErrorStatusStateProviderValue.update(
              status: ErrorStatus.vtopError);
        });
  }

  _vtopLoginAjaxRequest({required AjaxRequest ajaxRequest}) async {
    _ajaxRequestCommonHandler(
        ajaxRequest: ajaxRequest,
        ajaxRequestStatus200Action: () async {
          if (readVTOPActionsProviderValue.loginPageStatus ==
              VTOPPageStatus.processing) {
            log("Accepted ajaxRequest callback as till now no action was taken for loaded loginPage.");
            readVTOPActionsProviderValue.updateLoginPageStatus(
                status: VTOPPageStatus.loaded);
            readVTOPActionsProviderValue.updateVTOPStatus(
                status: VTOPStatus.studentLoginPage);
            readUserLoginStateProviderValue.updateCaptchaImage(bytes: null);
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
                String solvedCaptcha =
                    await getSolvedCaptcha(imageBytes: bytes);
                readUserLoginStateProviderValue.updateCaptchaImage(
                    bytes: bytes);
                readUserLoginStateProviderValue.setAutoCaptcha(
                    autoCaptcha: solvedCaptcha);
              } else {
                await FirebaseCrashlytics.instance.recordError(
                    "Unknown response _vtopLoginAjaxRequest", null,
                    reason: 'a non-fatal error');
              }
            });
          } else {
            log("Rejected ajaxRequest callback as till now action was already taken for loaded loginPage.");
          }
        },
        ajaxRequestStatus232Action: () {
          log("Session timed out.");
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.sessionTimedOut);
          settingSomeVars();
          runHeadlessInAppWebView();
        },
        ajaxRequestOtherStatusAction: () {
          log("Error occurred.");
          readErrorStatusStateProviderValue.update(
              status: ErrorStatus.vtopError);
          settingSomeVars();
          runHeadlessInAppWebView();
        });
  }

  _onLoadStopAction({required Uri? url}) async {
    _onLoadStopHandler(
      initialUrl: _initialUrl,
      url: url,
      headlessWebView: headlessWebView,
      homepageAction: () async {
        if (readVTOPActionsProviderValue.vtopStatus == VTOPStatus.noStatus) {
          log("Accepted onLoadStop callback as till now no action was taken for loaded VTOP.");
          // This condition is extremely crucial as it stops the endless loop of VTOP loading.
          // VTOP send onLoadStop request many times.
          // And when we click login on the new requests then the old requests login get a session time out.
          // And then the session time out request will call restart for WebView which will lead to an endless loop.
          readConnectionStatusStateProviderValue.update(
              status: ConnectionStatus.connected);
          readVTOPActionsProviderValue.updateVTOPStatus(
              status: VTOPStatus.homepage);
        } else {
          log("Rejected onLoadStop callback as till now action was already taken for loaded VTOP.");
        }
      },
      alreadyLoggedInAction: () {
        log("Accepted onLoadStop callback as till now no action was taken for loaded VTOP.");
        log("VTOP is already logged in.");
        readConnectionStatusStateProviderValue.update(
            status: ConnectionStatus.connected);
        readVTOPActionsProviderValue.updateVTOPStatus(
            status: VTOPStatus.sessionActive);
        readUserLoginStateProviderValue.updateLoginStatus(
            loginStatus: LoginResponseStatus.loggedIn);
      },
      sessionTimeOutAction: () {
        log("Session timed out.");
        log("Recreating HeadlessInAppWebView!");
        readVTOPActionsProviderValue.updateVTOPStatus(
            status: VTOPStatus.sessionTimedOut);
        settingSomeVars();
        runHeadlessInAppWebView();
      },
    );
  }
}

_onLoadStopHandler({
  required Uri? url,
  required HeadlessInAppWebView headlessWebView,
  required Function() homepageAction,
  required Function() alreadyLoggedInAction,
  required Function() sessionTimeOutAction,
  required String initialUrl,
}) async {
  headlessWebView.webViewController
      .evaluateJavascript(
          source: "new XMLSerializer().serializeToString(document);")
      .then((value) async {
    String initialVTOPHtml =
        '<html xmlns="http://www.w3.org/1999/xhtml"><head></head><body></body></html>';
    if (value != null) {
      if (value.contains(
          "You are logged out due to inactivity for more than 15 minutes")) {
        // If true means session timed out.

        sessionTimeOutAction();
      } else if (url.toString() == "${initialUrl}initialProcess" &&
          await headlessWebView.webViewController.getProgress() == 100 &&
          !(await headlessWebView.webViewController.isLoading()) &&
          value != initialVTOPHtml &&
          value.contains("V-TOP for Employee and Students")) {
        // If true means VTOP is loaded.

        homepageAction();
      } else if (url.toString() == initialUrl &&
          await headlessWebView.webViewController.getProgress() == 100 &&
          !(await headlessWebView.webViewController.isLoading()) &&
          value.contains("(STUDENT)")) {
        // If true means VTOP is already logged in and homepage is loaded.

        alreadyLoggedInAction();
      } else {
        // If true means no action taken for this onLoadStop callback.

        log("Rejected onLoadStop callback as VTOP was not loaded.");
      }
    }
  });
}

_ajaxRequestCommonHandler(
    {required AjaxRequest ajaxRequest,
    required Function() ajaxRequestStatus200Action,
    required Function() ajaxRequestStatus232Action,
    required Function() ajaxRequestOtherStatusAction}) async {
  if (ajaxRequest.status != 200) {
    await FirebaseCrashlytics.instance.recordError(
        "_ajaxRequestCommonHandler ajaxRequest.url: ${ajaxRequest.url}, ajaxRequest.status: ${ajaxRequest.status} encountered",
        null,
        reason: 'a non-fatal error');
  }
  if (ajaxRequest.status == 200) {
    // ajaxRequest.status == 200 means a successful operation without any issues.

    log("ajaxRequest.status: 200 encountered");
    ajaxRequestStatus200Action();
  } else if (ajaxRequest.status == 231) {
    // ajaxRequest.status == 231 loads the homepage for VTOP. Homepage not login page.
    // If user logged in then logged in homepage for VTOP is loaded.

    log("ajaxRequest.status: 231 encountered");
    ajaxRequestOtherStatusAction();
  } else if (ajaxRequest.status == 232) {
    // ajaxRequest.status == 232 means the Session Timed out.
    // The ajaxRequest.responseText should contain "You are logged out due to inactivity for more than 15 minutes"
    // ajaxRequest.responseText!.contains("You are logged out due to inactivity for more than 15 minutes") should be true.

    log("ajaxRequest.status: 232 encountered");
    ajaxRequestStatus232Action();
  } else if (ajaxRequest.status == 233) {
    // ajaxRequest.status == 233 executes same operation as ajaxRequest.status == 200.
    // But is still an error request.
    // Todo: Find the situation in which this status is encountered and then handle that suitably.

    log("ajaxRequest.status: 233 encountered");
    ajaxRequestOtherStatusAction();
  } else {
    // Any other ajaxRequest.status executes same operation as ajaxRequest.status == 200.

    log("ajaxRequest.status: ${ajaxRequest.status} encountered");
    ajaxRequestOtherStatusAction();
  }
}

_shouldOverrideUrlLoadingHandler(
    {required InAppWebViewController controller,
    required NavigationAction navigationAction,
    required String redirectFromUrl,
    required String initialUrl}) {
  String redirectToUrl = navigationAction.request.url.toString();

  if (redirectFromUrl == initialUrl &&
      redirectToUrl == "${initialUrl}initialProcess") {
    // It means url redirecting from https://vtop.vitbhopal.ac.in/vtop/ to https://vtop.vitbhopal.ac.in/vtop/initialProcess.
    // The VTOP initial url always redirects to this url as it is the homepage.

    log("Redirecting from https://vtop.vitbhopal.ac.in/vtop/ to https://vtop.vitbhopal.ac.in/vtop/initialProcess");
  } else {
    log("Redirecting from $redirectFromUrl to $redirectToUrl");
  }
}

void errorSnackBar({required BuildContext context, required String error}) {
  showCustomSnackBar(
    context: context,
    contentText: error,
    backgroundColor: Theme.of(context).colorScheme.errorContainer,
    duration: const Duration(days: 365),
    iconData: Icons.warning,
    iconAndTextColor: Theme.of(context).colorScheme.error,
  );
}

// class CustomErrorException implements Exception {
//   String cause;
//   CustomErrorException({required this.cause});
//
//   // Implement toString to make it easier to see information
//   // when using the print statement.
//   @override
//   String toString() {
//     return 'CustomErrorException{cause: $cause}';
//   }
// }
