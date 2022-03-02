import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../basicFunctionsAndWidgets/direct_pop.dart';
import '../basicFunctionsAndWidgets/proccessing_dialog.dart';
import '../basicFunctionsAndWidgets/stop_pop.dart';
import '../basicFunctionsAndWidgets/upper_case_text_formatter.dart';
import '../basicFunctionsAndWidgets/widget_size_limiter.dart';

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
    required this.onProcessingSomething,
  }) : super(key: key);

  final LoginSectionArguments arguments;
  final ValueChanged<String>? onCurrentStatus;
  final ValueChanged<Map<String, dynamic>>? onPerformSignIn;
  final ValueChanged<bool>? onPerformSignOut;
  final ValueChanged<Map<String, dynamic>>? onRefreshCaptcha;
  final ValueChanged<String> onVtopLoginErrorType;
  final ValueChanged<bool> onClearUnamePasswd;
  final ValueChanged<bool> onTryAutoLoginStatus;
  final ValueChanged<bool> onProcessingSomething;

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

  late Widget animationOfLoginScreen;

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

    animationOfLoginScreen = Image.asset(
      "assets/images/screens_animated_gifs/Flame_animated_illustrations_by_Icons8/Flame_Sign_In_transparent_by_Icons8.gif",
      scale: 0.1,
      width: widgetSizeProvider(
          fixedSize: 5000,
          sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
      height: widgetSizeProvider(
          fixedSize: 5000,
          sizeDecidingVariable: widget.arguments.screenBasedPixelHeight),
      key: const ValueKey<int>(0),
    );

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
          widget.onProcessingSomething.call(true);
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
              style: getDynamicTextStyle(
                  textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.87)),
                  sizeDecidingVariable: screenBasedPixelWidth),
              textAlign: TextAlign.center,
            ),
            dialogChildren: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: widgetSizeProvider(
                      fixedSize: 36,
                      sizeDecidingVariable:
                          widget.arguments.screenBasedPixelWidth),
                  width: widgetSizeProvider(
                      fixedSize: 36,
                      sizeDecidingVariable:
                          widget.arguments.screenBasedPixelWidth),
                  child: CircularProgressIndicator(
                    strokeWidth: widgetSizeProvider(
                        fixedSize: 4,
                        sizeDecidingVariable:
                            widget.arguments.screenBasedPixelWidth),
                  ),
                ),
                Text(
                  'Please wait...',
                  style: getDynamicTextStyle(
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.60)),
                      sizeDecidingVariable: screenBasedPixelWidth),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            barrierDismissible: false,
            screenBasedPixelHeight: screenBasedPixelHeight,
            screenBasedPixelWidth: screenBasedPixelWidth,
            onProcessingSomething: (bool value) {
              widget.onProcessingSomething.call(value);
            },
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
        widget.onProcessingSomething.call(true);
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
            style: getDynamicTextStyle(
                textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.87)),
                sizeDecidingVariable: screenBasedPixelWidth),
            textAlign: TextAlign.center,
          ),
          dialogChildren: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: widgetSizeProvider(
                    fixedSize: 36,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
                width: widgetSizeProvider(
                    fixedSize: 36,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
                child: CircularProgressIndicator(
                  strokeWidth: widgetSizeProvider(
                      fixedSize: 4,
                      sizeDecidingVariable:
                          widget.arguments.screenBasedPixelWidth),
                ),
              ),
              Text(
                'Re-requesting login page please wait...',
                style: getDynamicTextStyle(
                    textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.60)),
                    sizeDecidingVariable: screenBasedPixelWidth),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          barrierDismissible: false,
          screenBasedPixelHeight: screenBasedPixelHeight,
          screenBasedPixelWidth: screenBasedPixelWidth,
          onProcessingSomething: (bool value) {
            widget.onProcessingSomething.call(value);
          },
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
            : directPop(
                onProcessingSomething: (bool value) {
                  widget.onProcessingSomething.call(value);
                },
              ); //will stop popping login screen
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: widgetSizeProvider(
                              fixedSize: 700,
                              sizeDecidingVariable:
                                  widget.arguments.screenBasedPixelWidth),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            //Animation.
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return ScaleTransition(
                                      scale: animation, child: child);
                                },
                                child: SizedBox(
                                  height: widgetSizeProvider(
                                      fixedSize: 250,
                                      sizeDecidingVariable: widget
                                          .arguments.screenBasedPixelHeight),
                                  width: widgetSizeProvider(
                                      fixedSize: 250,
                                      sizeDecidingVariable: widget
                                          .arguments.screenBasedPixelWidth),
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
                                          left: widgetSizeProvider(
                                              fixedSize: 8,
                                              sizeDecidingVariable: widget
                                                  .arguments
                                                  .screenBasedPixelWidth),
                                          right: widgetSizeProvider(
                                              fixedSize: 8,
                                              sizeDecidingVariable: widget
                                                  .arguments
                                                  .screenBasedPixelWidth),
                                          top: widgetSizeProvider(
                                              fixedSize: 8,
                                              sizeDecidingVariable: widget
                                                  .arguments
                                                  .screenBasedPixelWidth),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .errorContainer,
                                                // border: Border.all(),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                    widgetSizeProvider(
                                                        fixedSize: 5,
                                                        sizeDecidingVariable: widget
                                                            .arguments
                                                            .screenBasedPixelWidth),
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          right: widgetSizeProvider(
                                                              fixedSize: 8,
                                                              sizeDecidingVariable:
                                                                  widget
                                                                      .arguments
                                                                      .screenBasedPixelWidth),
                                                          left: widgetSizeProvider(
                                                              fixedSize: 8,
                                                              sizeDecidingVariable:
                                                                  widget
                                                                      .arguments
                                                                      .screenBasedPixelWidth),
                                                        ),
                                                        child: Icon(
                                                          Icons.error,
                                                          size: widgetSizeProvider(
                                                              fixedSize: 24,
                                                              sizeDecidingVariable:
                                                                  widget
                                                                      .arguments
                                                                      .screenBasedPixelWidth),
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onErrorContainer,
                                                        ),
                                                      ),
                                                      Text(
                                                        widget.arguments
                                                            .vtopLoginErrorType,
                                                        style: getDynamicTextStyle(
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption
                                                                ?.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onErrorContainer),
                                                            sizeDecidingVariable:
                                                                screenBasedPixelWidth),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: widgetSizeProvider(
                                                        fixedSize: 51,
                                                        sizeDecidingVariable: widget
                                                            .arguments
                                                            .screenBasedPixelWidth),
                                                    height: widgetSizeProvider(
                                                        fixedSize: 40,
                                                        sizeDecidingVariable: widget
                                                            .arguments
                                                            .screenBasedPixelWidth),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      shape:
                                                          const StadiumBorder(),
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
                                                          focusColor: Colors
                                                              .black
                                                              .withOpacity(0.1),
                                                          highlightColor: Colors
                                                              .black
                                                              .withOpacity(0.1),
                                                          splashColor: Colors
                                                              .black
                                                              .withOpacity(0.1),
                                                          hoverColor: Colors
                                                              .black
                                                              .withOpacity(0.1),
                                                          child: Icon(
                                                            Icons
                                                                .close_outlined,
                                                            size: widgetSizeProvider(
                                                                fixedSize: 24,
                                                                sizeDecidingVariable:
                                                                    widget
                                                                        .arguments
                                                                        .screenBasedPixelWidth),
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onErrorContainer,
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
                                    left: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    right: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    top: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
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
                                                          .allow(RegExp(
                                                              "[0-9A-Z]")),
                                                    ],
                                                    validator: (String? value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please enter username';
                                                      }
                                                      return null;
                                                    },
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    suffixIcon: null,
                                                    obscureText: false,
                                                    enableSuggestions: true,
                                                    autocorrect: false,
                                                    enabled: !widget.arguments
                                                        .credentialsFound,
                                                    readOnly: widget.arguments
                                                        .credentialsFound,
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
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    suffixIcon: null,
                                                    obscureText: isObscure,
                                                    enableSuggestions: false,
                                                    autocorrect: false,
                                                    enabled: !widget.arguments
                                                        .credentialsFound,
                                                    readOnly: widget.arguments
                                                        .credentialsFound,
                                                  ),
                                                ],
                                              ),
                                              //Clear button on fake email & password text fields.
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  right: widgetSizeProvider(
                                                      fixedSize: 8,
                                                      sizeDecidingVariable: widget
                                                          .arguments
                                                          .screenBasedPixelWidth),
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

                                                        widget
                                                            .onClearUnamePasswd
                                                            .call(true);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .close_outlined,
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
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                          RegExp("[0-9A-Z]")),
                                                ],
                                                validator: (String? value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter username';
                                                  }
                                                  return null;
                                                },
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                suffixIcon: null,
                                                obscureText: false,
                                                enableSuggestions: true,
                                                autocorrect: false,
                                                enabled: true,
                                                readOnly: false,
                                              ),
                                              SizedBox(
                                                height: widgetSizeProvider(
                                                    fixedSize: 10,
                                                    sizeDecidingVariable: widget
                                                        .arguments
                                                        .screenBasedPixelHeight),
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
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                suffixIcon: SizedBox(
                                                  width: widgetSizeProvider(
                                                      fixedSize: 51,
                                                      sizeDecidingVariable: widget
                                                          .arguments
                                                          .screenBasedPixelWidth),
                                                  height: widgetSizeProvider(
                                                      fixedSize: 40,
                                                      sizeDecidingVariable: widget
                                                          .arguments
                                                          .screenBasedPixelWidth),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    shape:
                                                        const StadiumBorder(),
                                                    child: Tooltip(
                                                      message:
                                                          "Refresh Captcha",
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            isObscure =
                                                                !isObscure;
                                                          });
                                                        },
                                                        customBorder:
                                                            const StadiumBorder(),
                                                        focusColor: Colors.black
                                                            .withOpacity(0.1),
                                                        highlightColor: Colors
                                                            .black
                                                            .withOpacity(0.1),
                                                        splashColor: Colors
                                                            .black
                                                            .withOpacity(0.1),
                                                        hoverColor: Colors.black
                                                            .withOpacity(0.1),
                                                        child: Icon(
                                                          isObscure
                                                              ? Icons.visibility
                                                              : Icons
                                                                  .visibility_off,
                                                          size: widgetSizeProvider(
                                                              fixedSize: 24,
                                                              sizeDecidingVariable:
                                                                  widget
                                                                      .arguments
                                                                      .screenBasedPixelWidth),
                                                          // color: Colors.blue,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
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
                                    left: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    right: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    top: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        //Captcha display.
                                        Container(
                                          padding: EdgeInsets.all(
                                            widgetSizeProvider(
                                                fixedSize: 20,
                                                sizeDecidingVariable: widget
                                                    .arguments
                                                    .screenBasedPixelWidth),
                                          ),
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
                                                border: Border.all(
                                                  width: widgetSizeProvider(
                                                      fixedSize: 0.5,
                                                      sizeDecidingVariable: widget
                                                          .arguments
                                                          .screenBasedPixelWidth),
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                  widgetSizeProvider(
                                                      fixedSize: 3,
                                                      sizeDecidingVariable: widget
                                                          .arguments
                                                          .screenBasedPixelWidth),
                                                )),
                                              ),
                                              height: widgetSizeProvider(
                                                  fixedSize: 45,
                                                  sizeDecidingVariable: widget
                                                      .arguments
                                                      .screenBasedPixelWidth),
                                              width: widgetSizeProvider(
                                                  fixedSize: 180,
                                                  sizeDecidingVariable: widget
                                                      .arguments
                                                      .screenBasedPixelWidth),
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
                                          width: widgetSizeProvider(
                                              fixedSize: 70,
                                              sizeDecidingVariable: widget
                                                  .arguments
                                                  .screenBasedPixelWidth),
                                          height: widgetSizeProvider(
                                              fixedSize: 40,
                                              sizeDecidingVariable: widget
                                                  .arguments
                                                  .screenBasedPixelWidth),
                                          child: Tooltip(
                                            message: "Refresh Captcha",
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                minimumSize:
                                                    MaterialStateProperty.all<
                                                        Size?>(
                                                  Size.fromHeight(
                                                    widgetSizeProvider(
                                                        fixedSize: 56,
                                                        sizeDecidingVariable:
                                                            screenBasedPixelHeight),
                                                  ),
                                                ),
                                                // backgroundColor: MaterialStateProperty.all(
                                                //     const Color(0xff04294f)),
                                                padding:
                                                    MaterialStateProperty.all(
                                                  EdgeInsets.only(
                                                    left: widgetSizeProvider(
                                                        fixedSize: 20,
                                                        sizeDecidingVariable:
                                                            screenBasedPixelWidth),
                                                    right: widgetSizeProvider(
                                                        fixedSize: 20,
                                                        sizeDecidingVariable:
                                                            screenBasedPixelWidth),
                                                  ),
                                                ),
                                                textStyle:
                                                    MaterialStateProperty.all(
                                                  getDynamicTextStyle(
                                                      sizeDecidingVariable:
                                                          screenBasedPixelWidth,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyText1),
                                                ),
                                                shape: MaterialStateProperty
                                                    .all<StadiumBorder>(
                                                  const StadiumBorder(),
                                                ),
                                              ),
                                              onPressed: () {
                                                // _controller3 =
                                                //     TextEditingController(text: "");
                                                signInCredentialsMap = {
                                                  "uname":
                                                      '${_controller?.value.text.toUpperCase()}',
                                                  "passwd":
                                                      '${_controller2?.value.text}',
                                                  "refreshingCaptcha": true,
                                                };
                                                widget.onRefreshCaptcha?.call(
                                                    signInCredentialsMap);
                                              },
                                              child: Icon(
                                                Icons.refresh,
                                                size: widgetSizeProvider(
                                                    fixedSize: 24,
                                                    sizeDecidingVariable: widget
                                                        .arguments
                                                        .screenBasedPixelWidth),
                                                // color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                //Captcha.
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    right: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    top: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                  ),
                                  child: loginTextFormFields(
                                    helperText: '🤖🤖🤖',
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
                                SizedBox(
                                  height: widgetSizeProvider(
                                      fixedSize: 10,
                                      sizeDecidingVariable: widget
                                          .arguments.screenBasedPixelHeight),
                                ),
                                //Auto sign-in checkbox tile.
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    right: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    top: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                  ),
                                  child: LabeledCheckbox(
                                    onChanged: (bool? value) {
                                      widget.onTryAutoLoginStatus.call(
                                          !widget.arguments.tryAutoLoginStatus);
                                    },
                                    labelWidget: Text(
                                      'Auto sign-in?',
                                      style: getDynamicTextStyle(
                                          sizeDecidingVariable:
                                              screenBasedPixelWidth,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyText1),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: widgetSizeProvider(
                                          fixedSize: 8,
                                          sizeDecidingVariable: widget
                                              .arguments.screenBasedPixelWidth),
                                    ),
                                    value: widget.arguments.tryAutoLoginStatus,
                                  ),
                                ),
                                //Sign-in button.
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    right: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    top: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    bottom: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                  ),
                                  child: customElevatedButton(
                                    onPressed: () async {
                                      // Validate returns true if the form is valid, or false otherwise.
                                      FocusScopeNode currentFocus =
                                          FocusScope.of(context);
                                      if (!currentFocus.hasPrimaryFocus &&
                                          currentFocus.focusedChild != null) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
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
                                            style: getDynamicTextStyle(
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .headline6
                                                    ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.87)),
                                                sizeDecidingVariable:
                                                    screenBasedPixelWidth),
                                            textAlign: TextAlign.center,
                                          ),
                                          dialogChildren: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: widgetSizeProvider(
                                                    fixedSize: 36,
                                                    sizeDecidingVariable: widget
                                                        .arguments
                                                        .screenBasedPixelWidth),
                                                width: widgetSizeProvider(
                                                    fixedSize: 36,
                                                    sizeDecidingVariable: widget
                                                        .arguments
                                                        .screenBasedPixelWidth),
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: widgetSizeProvider(
                                                      fixedSize: 4,
                                                      sizeDecidingVariable: widget
                                                          .arguments
                                                          .screenBasedPixelWidth),
                                                ),
                                              ),
                                              Text(
                                                'Please wait...',
                                                style: getDynamicTextStyle(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurface
                                                                .withOpacity(
                                                                    0.60)),
                                                    sizeDecidingVariable:
                                                        screenBasedPixelWidth),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          barrierDismissible: false,
                                          screenBasedPixelHeight:
                                              screenBasedPixelHeight,
                                          screenBasedPixelWidth:
                                              screenBasedPixelWidth,
                                          onProcessingSomething: (bool value) {
                                            widget.onProcessingSomething
                                                .call(value);
                                          },
                                        ).then((_) =>
                                            isFirstDialogShowing = false);
                                        debugPrint("dialogBox initiated");
                                        signInCredentialsMap = {
                                          "uname":
                                              '${_controller?.value.text.toUpperCase()}',
                                          "passwd":
                                              '${_controller2?.value.text}',
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
                                    ),
                                  ),
                                ),
                                //User note.
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    right: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                    top: widgetSizeProvider(
                                        fixedSize: 8,
                                        sizeDecidingVariable: widget
                                            .arguments.screenBasedPixelWidth),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Notes:-",
                                        style: getDynamicTextStyle(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                            sizeDecidingVariable:
                                                screenBasedPixelWidth),
                                      ),
                                      Text(
                                        "1. We have limited Auto sign-in tries to 1 time only as it could fail due to various reasons.\n2. Also auto sign-in gets disabled on manual logout by user so that the user don't get stuck in an endless login & logout loop. \n3. This app don't run in background so it can't extend the user session time if it is kept in background.",
                                        style: getDynamicTextStyle(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyText2,
                                            sizeDecidingVariable:
                                                screenBasedPixelWidth),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
          // backgroundColor: MaterialStateProperty.all(const Color(0xff04294f)),
          padding: MaterialStateProperty.all(EdgeInsets.only(
            top: widgetSizeProvider(
                fixedSize: 16,
                sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
            bottom: widgetSizeProvider(
                fixedSize: 16,
                sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
            left: widgetSizeProvider(
                fixedSize: 30,
                sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
            right: widgetSizeProvider(
                fixedSize: 30,
                sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          )),
          textStyle: MaterialStateProperty.all(
            getDynamicTextStyle(
                textStyle: Theme.of(context).textTheme.button,
                sizeDecidingVariable: screenBasedPixelWidth),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                widgetSizeProvider(
                    fixedSize: 20,
                    sizeDecidingVariable:
                        widget.arguments.screenBasedPixelWidth),
              ),
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
      style: getDynamicTextStyle(
          textStyle: Theme.of(context).textTheme.subtitle1,
          sizeDecidingVariable: screenBasedPixelWidth),
      cursorWidth: widgetSizeProvider(
          fixedSize: 2,
          sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
      // initialValue: 'Input text',
      // maxLength: 20,
      decoration: InputDecoration(
        filled: true,
        // fillColor: Color(0xff04294f),
        // icon: const Icon(Icons.favorite),
        labelText: labelText,
        labelStyle: getDynamicTextStyle(
            textStyle:
                Theme.of(context).inputDecorationTheme.labelStyle?.copyWith(
                      height: 1.0,
                    ),
            sizeDecidingVariable: screenBasedPixelWidth),

        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: widgetSizeProvider(
              fixedSize: 13.5,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          horizontal: widgetSizeProvider(
              fixedSize: 13.5,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
        ),
        // labelStyle: TextStyle(
        //   color: Color(0xFF6200EE),
        // ),
        helperText: helperText,
        helperStyle: getDynamicTextStyle(
            textStyle: Theme.of(context).inputDecorationTheme.helperStyle,
            sizeDecidingVariable: screenBasedPixelWidth),

        floatingLabelStyle: getDynamicTextStyle(
            textStyle:
                Theme.of(context).inputDecorationTheme.floatingLabelStyle,
            sizeDecidingVariable: screenBasedPixelWidth),

        errorStyle: getDynamicTextStyle(
            textStyle: Theme.of(context).inputDecorationTheme.errorStyle,
            sizeDecidingVariable: screenBasedPixelWidth),

        enabledBorder: const UnderlineInputBorder(
            // borderSide: BorderSide(color: Color(0xFF6200EE)),
            ),
        suffixIconConstraints: BoxConstraints(
          minHeight: widgetSizeProvider(
              fixedSize: 24,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
          minWidth: widgetSizeProvider(
              fixedSize: 24,
              sizeDecidingVariable: widget.arguments.screenBasedPixelWidth),
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

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    Key? key,
    required this.labelWidget,
    required this.padding,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final Widget labelWidget;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(child: labelWidget),
            Checkbox(
              value: value,
              onChanged: (bool? newValue) {
                onChanged(newValue!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
