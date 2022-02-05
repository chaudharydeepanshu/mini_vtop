import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../basicFunctions/direct_pop.dart';
import '../basicFunctions/proccessing_dialog.dart';
import '../basicFunctions/stop_pop.dart';
import '../basicFunctions/upper_case_text_formatter.dart';

class LoginSection extends StatefulWidget {
  const LoginSection({
    Key? key,
    required this.arguments,
    this.onCurrentStatus,
    this.onPerformSignIn,
    this.onPerformSignOut,
    this.onRefreshCaptcha,
    required this.onVtopLoginErrorType,
    required this.onClearUnamePasswd,
    required this.onTryAutoLoginStatus,
  }) : super(key: key);

  final LoginSectionArguments arguments;
  final ValueChanged<String>? onCurrentStatus;
  final ValueChanged<Map<String, dynamic>>? onPerformSignIn;
  final ValueChanged<bool>? onPerformSignOut;
  final ValueChanged<Map<String, dynamic>>? onRefreshCaptcha;
  final ValueChanged<String> onVtopLoginErrorType;
  final ValueChanged<bool> onClearUnamePasswd;
  final ValueChanged<bool> onTryAutoLoginStatus;

  @override
  _LoginSectionState createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection> {
  TextEditingController? _controller;
  TextEditingController? _controller2;
  TextEditingController? _controller3;

  late HeadlessInAppWebView? headlessWebView;
  late Image? image;
  late String? currentStatus;
  String? uname = "";
  String? passwd = "";
  String? captchaCheck = "";
  Map<String, dynamic> signInCredentialsMap = {};

  @override
  void didUpdateWidget(LoginSection oldWidget) {
    if (oldWidget.arguments.image != widget.arguments.image) {
      image = widget.arguments.image;
    }
    if (oldWidget.arguments.autoCaptcha != widget.arguments.autoCaptcha) {
      _controller3 = TextEditingController(text: widget.arguments.autoCaptcha);
    }

    super.didUpdateWidget(oldWidget);
  }
  //setState in parent widget will not completely rebuild its inner Stateful Widget so the initstate of child widget will not rerun and updated argument value doesn't update in the ui. To bypass that we can redefine initstate values also in build method but it is better to just use the didUpdateWidget as it is designed for that. Another method would be to just assign a completely new key to the child widget which will force complete rebuild

  Widget animationOfLoginScreen = Image.asset(
    "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_Sign_In_transparent_by_Icons8.gif",
    scale: 0.1,
    width: 5000,
    height: 5000,
    key: const ValueKey<int>(0),
  );

  late Widget usernameRealField;
  late Widget passwordRealField;

  late Widget usernameFakeField;
  late Widget passwordFakeField;

  late Widget credentialsWidget;

  final _formKey = GlobalKey<FormState>();
  bool isObscure = true;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.arguments.userEnteredUname);
    _controller2 =
        TextEditingController(text: widget.arguments.userEnteredPasswd);
    _controller3 = TextEditingController(text: widget.arguments.autoCaptcha);

    image = widget.arguments.image;

    currentStatus = widget.arguments.currentStatus;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.arguments.userEnteredUname.isNotEmpty &&
          widget.arguments.userEnteredPasswd.isNotEmpty &&
          widget.arguments.autoCaptcha.isNotEmpty &&
          widget.arguments.tryAutoLoginStatus == true) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
        if (_formKey.currentState!.validate()) {
          customDialogBox(
            isDialogShowing: isFirstDialogShowing,
            context: context,
            onIsDialogShowing: (bool value) {
              setState(() {
                isFirstDialogShowing = value;
              });
            },
            dialogTitle: Text(
              'Sending login request',
              style: TextStyle(fontSize: screenBasedPixelWidth * 24),
              textAlign: TextAlign.center,
            ),
            dialogChildren: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenBasedPixelWidth * 36,
                  width: screenBasedPixelWidth * 36,
                  child: CircularProgressIndicator(
                    strokeWidth: screenBasedPixelWidth * 4.0,
                  ),
                ),
                Text(
                  'Please wait...',
                  style: TextStyle(fontSize: screenBasedPixelWidth * 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            barrierDismissible: false,
            screenBasedPixelHeight: screenBasedPixelHeight,
            screenBasedPixelWidth: screenBasedPixelWidth,
          ).then((_) => isFirstDialogShowing = false);
          debugPrint("dialogBox initiated");
          signInCredentialsMap = {
            "uname": '${_controller?.value.text.toUpperCase()}',
            "passwd": '${_controller2?.value.text}',
            "captchaCheck": '${_controller3?.value.text.toUpperCase()}',
            "refreshingCaptcha": true,
            "processingSomething": true,
          };
          widget.onPerformSignIn?.call(signInCredentialsMap);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _controller2?.dispose();
    _controller3?.dispose();
  }

  bool isFirstDialogShowing = false;
  bool isSecondDialogShowing = false;

  late double screenBasedPixelWidth;
  late double screenBasedPixelHeight;

  @override
  Widget build(BuildContext context) {
    screenBasedPixelWidth = widget.arguments.screenBasedPixelWidth;
    screenBasedPixelHeight = widget.arguments.screenBasedPixelHeight;

    if (widget.arguments.vtopLoginErrorType != "None" &&
        isFirstDialogShowing == true &&
        isSecondDialogShowing == false &&
        widget.arguments.processingSomething == true) {
      Navigator.of(context).pop();
      debugPrint("credential dialogBox popped");
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        customDialogBox(
          isDialogShowing: isSecondDialogShowing,
          context: context,
          onIsDialogShowing: (bool value) {
            setState(() {
              isSecondDialogShowing = value;
            });
          },
          dialogTitle: Text(
            'Sign-in Failed',
            style: TextStyle(fontSize: screenBasedPixelWidth * 24),
            textAlign: TextAlign.center,
          ),
          dialogChildren: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: screenBasedPixelWidth * 36,
                width: screenBasedPixelWidth * 36,
                child: CircularProgressIndicator(
                  strokeWidth: screenBasedPixelWidth * 4.0,
                ),
              ),
              Text(
                'Re-requesting login page please wait...',
                style: TextStyle(fontSize: screenBasedPixelWidth * 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          barrierDismissible: false,
          screenBasedPixelHeight: screenBasedPixelHeight,
          screenBasedPixelWidth: screenBasedPixelWidth,
        ).then((_) => isSecondDialogShowing = false);
      });
    }
    debugPrint("isDialogShowing: $isFirstDialogShowing");
    if (widget.arguments.processingSomething == false &&
        isSecondDialogShowing == true) {
      // _controller3 = TextEditingController(text: "");
      Future.delayed(const Duration(milliseconds: 500), () async {
        Navigator.of(context).pop();
        debugPrint("dialogBox popped");
      });
    }

    return WillPopScope(
      onWillPop: () {
        return !isFirstDialogShowing
            ? stopPop()
            : directPop(); //will stop popping login screen
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      //Animation.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: SizedBox(
                            height: screenBasedPixelWidth * 250,
                            width: screenBasedPixelWidth * 250,
                            child: animationOfLoginScreen,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          widget.arguments.vtopLoginErrorType != "None"
                              //Error warning.
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    left: screenBasedPixelWidth * 8.0,
                                    right: screenBasedPixelWidth * 8.0,
                                    top: screenBasedPixelWidth * 8.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xfff04e23),
                                          // border: Border.all(),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(
                                              screenBasedPixelWidth * 5.0,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right:
                                                        screenBasedPixelWidth *
                                                            8.0,
                                                    left:
                                                        screenBasedPixelWidth *
                                                            8.0,
                                                  ),
                                                  child: Icon(
                                                    Icons.error,
                                                    size:
                                                        screenBasedPixelWidth *
                                                            24,
                                                  ),
                                                ),
                                                Text(
                                                  widget.arguments
                                                      .vtopLoginErrorType,
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenBasedPixelWidth *
                                                            15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width:
                                                  screenBasedPixelWidth * 51.0,
                                              height:
                                                  screenBasedPixelHeight * 40,
                                              child: Material(
                                                color: Colors.transparent,
                                                shape: const StadiumBorder(),
                                                child: Tooltip(
                                                  message: "Close",
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        widget
                                                            .onVtopLoginErrorType
                                                            .call("None");
                                                      });
                                                    },
                                                    customBorder:
                                                        const StadiumBorder(),
                                                    focusColor: Colors.black
                                                        .withOpacity(0.1),
                                                    highlightColor: Colors.black
                                                        .withOpacity(0.1),
                                                    splashColor: Colors.black
                                                        .withOpacity(0.1),
                                                    hoverColor: Colors.black
                                                        .withOpacity(0.1),
                                                    child: Icon(
                                                      Icons.close_outlined,
                                                      size:
                                                          screenBasedPixelWidth *
                                                              24,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          Padding(
                            padding: EdgeInsets.only(
                                left: screenBasedPixelWidth * 8.0,
                                right: screenBasedPixelWidth * 8.0,
                                top: screenBasedPixelWidth * 8.0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: widget.arguments.credentialsFound
                                  //Existing credentials display.
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        //Fake email & password text fields.
                                        Column(
                                          children: [
                                            loginTextFormFields(
                                              helperText: null,
                                              controller: _controller,
                                              onChanged: (String value) {
                                                setState(() {
                                                  uname = value;
                                                });
                                              },
                                              labelText: 'Username',
                                              inputFormatters: [
                                                UpperCaseTextFormatter(),
                                                FilteringTextInputFormatter
                                                    .allow(RegExp("[0-9A-Z]")),
                                              ],
                                              validator: (String? value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter username';
                                                }
                                                return null;
                                              },
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              suffixIcon: null,
                                              obscureText: false,
                                              enableSuggestions: true,
                                              autocorrect: false,
                                              enabled: !widget
                                                  .arguments.credentialsFound,
                                              readOnly: widget
                                                  .arguments.credentialsFound,
                                            ),
                                            loginTextFormFields(
                                              helperText: null,
                                              controller: _controller2,
                                              onChanged: (String value) {
                                                setState(() {
                                                  passwd = value;
                                                });
                                              },
                                              labelText: 'Password',
                                              inputFormatters: [],
                                              validator: (String? value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter password';
                                                }
                                                return null;
                                              },
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              suffixIcon: null,
                                              obscureText: isObscure,
                                              enableSuggestions: false,
                                              autocorrect: false,
                                              enabled: !widget
                                                  .arguments.credentialsFound,
                                              readOnly: widget
                                                  .arguments.credentialsFound,
                                            ),
                                          ],
                                        ),
                                        //Clear button on fake email & password text fields.
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: screenBasedPixelWidth * 8.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              customElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _controller =
                                                        TextEditingController(
                                                            text: "");
                                                    _controller2 =
                                                        TextEditingController(
                                                            text: "");
                                                  });

                                                  widget.onClearUnamePasswd
                                                      .call(true);
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.close_outlined,
                                                      size:
                                                          screenBasedPixelWidth *
                                                              24.0,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          screenBasedPixelWidth *
                                                              8,
                                                    ),
                                                    Text(
                                                      "Clear",
                                                      style: GoogleFonts.lato(
                                                        color: Colors.white,
                                                        fontSize:
                                                            screenBasedPixelWidth *
                                                                17.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  //Real email & password text fields.
                                  : Column(
                                      children: [
                                        loginTextFormFields(
                                          helperText: 'Ex:- 20BCEXXXXX',
                                          controller: _controller,
                                          onChanged: (String value) {
                                            setState(() {
                                              uname = value;
                                            });
                                          },
                                          labelText: 'Username',
                                          inputFormatters: [
                                            UpperCaseTextFormatter(),
                                            FilteringTextInputFormatter.allow(
                                                RegExp("[0-9A-Z]")),
                                          ],
                                          validator: (String? value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter username';
                                            }
                                            return null;
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          suffixIcon: null,
                                          obscureText: false,
                                          enableSuggestions: true,
                                          autocorrect: false,
                                          enabled: true,
                                          readOnly: false,
                                        ),
                                        SizedBox(
                                          height: screenBasedPixelHeight * 10,
                                        ),
                                        loginTextFormFields(
                                          helperText: 'Ex:- password123',
                                          controller: _controller2,
                                          onChanged: (String value) {
                                            setState(() {
                                              passwd = value;
                                            });
                                          },
                                          labelText: 'Password',
                                          inputFormatters: [],
                                          validator: (String? value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter password';
                                            }
                                            return null;
                                          },
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              isObscure
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              size:
                                                  screenBasedPixelHeight * 24.0,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isObscure = !isObscure;
                                              });
                                            },
                                          ),
                                          obscureText: isObscure,
                                          enableSuggestions: false,
                                          autocorrect: false,
                                          enabled: true,
                                          readOnly: false,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          //Captcha display & captcha refresh button.
                          Padding(
                            padding: EdgeInsets.only(
                              left: screenBasedPixelWidth * 8.0,
                              right: screenBasedPixelWidth * 8.0,
                              top: screenBasedPixelWidth * 8.0,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //Captcha display.
                                  Container(
                                    padding: EdgeInsets.all(
                                        screenBasedPixelWidth * 20.0),
                                    child: Shimmer(
                                      duration: const Duration(
                                          seconds: 1), //Default value
                                      interval: const Duration(
                                          seconds:
                                              0), //Default value: Duration(seconds: 0)
                                      color: Colors.pink, //Default value
                                      colorOpacity: 0.2, //Default value
                                      enabled: widget.arguments
                                          .refreshingCaptcha, //Default value
                                      direction: const ShimmerDirection
                                          .fromLTRB(), //Default Value
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 0.5),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  screenBasedPixelWidth * 3.0)),
                                        ),
                                        height: screenBasedPixelHeight * 45,
                                        width: screenBasedPixelWidth * 180,
                                        child: widget.arguments
                                                    .refreshingCaptcha ==
                                                true
                                            ? const SizedBox()
                                            : image,
                                      ),
                                    ),
                                    // Html(
                                    //   data: serializedDocument,
                                    // ),
                                    // Text("Document: $serializedDocument"),
                                  ),
                                  //Refresh captcha button.
                                  SizedBox(
                                    width: screenBasedPixelWidth * 51,
                                    height: screenBasedPixelHeight * 40.0,
                                    child: Material(
                                      color: Colors.transparent,
                                      shape: const StadiumBorder(),
                                      child: Tooltip(
                                        message: "Refresh Captcha",
                                        child: InkWell(
                                          onTap: () {
                                            // _controller3 =
                                            //     TextEditingController(text: "");
                                            signInCredentialsMap = {
                                              "uname":
                                                  '${_controller?.value.text.toUpperCase()}',
                                              "passwd":
                                                  '${_controller2?.value.text}',
                                              "refreshingCaptcha": true,
                                            };
                                            widget.onRefreshCaptcha
                                                ?.call(signInCredentialsMap);
                                          },
                                          customBorder: const StadiumBorder(),
                                          focusColor:
                                              Colors.black.withOpacity(0.1),
                                          highlightColor:
                                              Colors.black.withOpacity(0.1),
                                          splashColor:
                                              Colors.black.withOpacity(0.1),
                                          hoverColor:
                                              Colors.black.withOpacity(0.1),
                                          child: Icon(
                                            Icons.refresh,
                                            size: screenBasedPixelHeight * 24,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // ElevatedButton(
                                  //   onPressed: () {
                                  //     signInCredentialsMap = {
                                  //       "uname": '${_controller?.value.text.toUpperCase()}',
                                  //       "passwd": '${_controller2?.value.text}',
                                  //       "refreshingCaptcha": true,
                                  //     };
                                  //     widget.onRefreshCaptcha?.call(signInCredentialsMap);
                                  //   },
                                  //   child: const Text("Refresh Captcha"),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          //Captcha.
                          Padding(
                            padding: EdgeInsets.only(
                                left: screenBasedPixelWidth * 8.0,
                                right: screenBasedPixelWidth * 8.0,
                                top: screenBasedPixelWidth * 8.0),
                            child: loginTextFormFields(
                              helperText: '',
                              controller: _controller3,
                              onChanged: (String value) {
                                setState(() {
                                  captchaCheck = value;
                                });
                              },
                              labelText: 'Captcha',
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9A-Z]")),
                              ],
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter captcha';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              suffixIcon: null,
                              obscureText: false,
                              enableSuggestions: false,
                              autocorrect: false,
                              enabled: true,
                              readOnly: false,
                            ),
                          ),
                          //Auto sign-in checkbox tile.
                          CheckboxListTile(
                            title: Text(
                              'Auto sign-in?',
                              style: TextStyle(
                                  fontSize: screenBasedPixelWidth * 16),
                            ),
                            value: widget.arguments.tryAutoLoginStatus,
                            onChanged: (bool? value) {
                              widget.onTryAutoLoginStatus
                                  .call(!widget.arguments.tryAutoLoginStatus);
                            },
                          ),
                          //Sign-in button.
                          Padding(
                            padding: EdgeInsets.only(
                                left: screenBasedPixelWidth * 8.0,
                                right: screenBasedPixelWidth * 8.0,
                                top: 8.0,
                                bottom: screenBasedPixelWidth * 8.0),
                            child: customElevatedButton(
                              onPressed: () async {
                                // Validate returns true if the form is valid, or false otherwise.
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus &&
                                    currentFocus.focusedChild != null) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                                if (_formKey.currentState!.validate()) {
                                  customDialogBox(
                                    isDialogShowing: isFirstDialogShowing,
                                    context: context,
                                    onIsDialogShowing: (bool value) {
                                      setState(() {
                                        isFirstDialogShowing = value;
                                      });
                                    },
                                    dialogTitle: Text(
                                      'Sending login request',
                                      style: TextStyle(
                                          fontSize: screenBasedPixelWidth * 24),
                                      textAlign: TextAlign.center,
                                    ),
                                    dialogChildren: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: screenBasedPixelWidth * 36,
                                          width: screenBasedPixelWidth * 36,
                                          child: CircularProgressIndicator(
                                            strokeWidth:
                                                screenBasedPixelWidth * 4.0,
                                          ),
                                        ),
                                        Text(
                                          'Please wait...',
                                          style: TextStyle(
                                              fontSize:
                                                  screenBasedPixelWidth * 20),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    barrierDismissible: false,
                                    screenBasedPixelHeight:
                                        screenBasedPixelHeight,
                                    screenBasedPixelWidth:
                                        screenBasedPixelWidth,
                                  ).then((_) => isFirstDialogShowing = false);
                                  debugPrint("dialogBox initiated");
                                  signInCredentialsMap = {
                                    "uname":
                                        '${_controller?.value.text.toUpperCase()}',
                                    "passwd": '${_controller2?.value.text}',
                                    "captchaCheck":
                                        '${_controller3?.value.text.toUpperCase()}',
                                    "refreshingCaptcha": true,
                                    "processingSomething": true,
                                  };
                                  widget.onPerformSignIn
                                      ?.call(signInCredentialsMap);
                                }
                              },
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  textStyle:
                                      Theme.of(context).textTheme.headline1,
                                  // fontSize: 20,
                                  fontSize: screenBasedPixelWidth * 20,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                          //User note.
                          Padding(
                            padding: EdgeInsets.only(
                                left: screenBasedPixelWidth * 8.0,
                                right: screenBasedPixelWidth * 8.0,
                                top: screenBasedPixelWidth * 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Notes:-",
                                  style: TextStyle(
                                      fontSize: screenBasedPixelWidth * 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "We have limited Auto sign-in tries to 1 time only as it could fail due to various reasons.\nAlso auto sign-in gets disabled on manual logout by user so that the user don't get stuck in an endless login & logout loop.",
                                  style: TextStyle(
                                      fontSize: screenBasedPixelWidth * 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FittedBox customElevatedButton({
    required void Function()? onPressed,
    required Widget? child,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xff04294f)),
          padding: MaterialStateProperty.all(EdgeInsets.only(
            top: screenBasedPixelWidth * 16.0,
            bottom: screenBasedPixelWidth * 16.0,
            left: screenBasedPixelWidth * 30.0,
            right: screenBasedPixelWidth * 30.0,
          )),
          textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 20)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenBasedPixelWidth * 20.0),
            ),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }

  TextFormField loginTextFormFields({
    required String labelText,
    required TextEditingController? controller,
    required String? helperText,
    required String? Function(String?)? validator,
    required List<TextInputFormatter>? inputFormatters,
    required ValueChanged<String> onChanged,
    required AutovalidateMode? autovalidateMode,
    required Widget? suffixIcon,
    required bool obscureText,
    required bool enableSuggestions,
    required bool autocorrect,
    required bool? enabled,
    required bool readOnly,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: screenBasedPixelWidth * 16.0,
        height: 1.0,
      ),
      cursorWidth: screenBasedPixelWidth * 2.0,
      // initialValue: 'Input text',
      // maxLength: 20,
      decoration: InputDecoration(
        filled: true,
        // fillColor: Color(0xff04294f),
        // icon: const Icon(Icons.favorite),
        labelText: labelText,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: screenBasedPixelWidth * 15.9,
          height: 1.0,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenBasedPixelHeight * 13.5,
          horizontal: screenBasedPixelWidth * 13.5,
        ),
        // labelStyle: TextStyle(
        //   color: Color(0xFF6200EE),
        // ),
        helperText: helperText,
        helperStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: screenBasedPixelWidth * 12.0,
        ),
        floatingLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: screenBasedPixelWidth * 15.9,
          height: 1.0,
        ),
        errorStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: screenBasedPixelWidth * 12.0,
        ),

        enabledBorder: const UnderlineInputBorder(
            // borderSide: BorderSide(color: Color(0xFF6200EE)),
            ),
        suffixIcon: suffixIcon,
      ),
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      obscuringCharacter: "*",
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      autovalidateMode: autovalidateMode,
      validator: validator,
      inputFormatters: inputFormatters,
      onChanged: (String value) {
        onChanged.call(value);
      },
    );
  }
}

class LoginSectionArguments {
  String currentStatus;
  String userEnteredUname;
  String userEnteredPasswd;
  // HeadlessInAppWebView headlessWebView;
  bool processingSomething;
  Image? image;
  bool refreshingCaptcha;
  String currentFullUrl;
  String vtopLoginErrorType;
  bool credentialsFound;
  String autoCaptcha;
  bool tryAutoLoginStatus;
  double screenBasedPixelWidth;
  double screenBasedPixelHeight;

  LoginSectionArguments({
    required this.currentStatus,
    required this.userEnteredUname,
    required this.userEnteredPasswd,
    //   required this.headlessWebView,
    required this.image,
    required this.processingSomething,
    required this.refreshingCaptcha,
    required this.currentFullUrl,
    required this.vtopLoginErrorType,
    required this.credentialsFound,
    required this.autoCaptcha,
    required this.tryAutoLoginStatus,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
  });
}
