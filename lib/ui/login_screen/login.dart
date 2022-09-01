import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mini_vtop/state/user_login_state.dart';
import 'package:mini_vtop/state/vtop_actions.dart';
import 'package:mini_vtop/ui/login_screen/components/control_teddy.dart';
import 'package:mini_vtop/ui/login_screen/components/login_tracking_text_input.dart';
import 'package:shimmer/shimmer.dart';

import '../../state/providers.dart';
import '../../state/webview_state.dart';
import '../home_screen/home_screen.dart';
import 'components/forgot_user_id_screen.dart';
import 'components/upper_case_text_formatter.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("VTOP Login"),
          centerTitle: true,
        ),
        body: const SafeArea(
          child: TeddyLoginScreen(),
        ),
      ),
    );
  }
}

class TeddyLoginScreen extends StatefulWidget {
  const TeddyLoginScreen({Key? key}) : super(key: key);

  @override
  State<TeddyLoginScreen> createState() => _TeddyLoginScreenState();
}

class _TeddyLoginScreenState extends State<TeddyLoginScreen> {
  late ControlTeddy controlTeddy;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controlTeddy = ControlTeddy();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String password = "";
  String registrationNumber = "";
  String captcha = "";
  bool autoLogin = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // padding: EdgeInsets.only(
      //     left: 20.0, right: 20.0, top: devicePadding.top + 50.0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Container(
          //   height: 200,
          //   padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          //   child: RiveAnimation.asset(
          //     "assets/rive/animated_login_screen.riv",
          //     animations: const ['idle', 'curves'],
          //     alignment: Alignment.bottomCenter,
          //     fit: BoxFit.contain,
          //     onInit: _controlTeddy._onRiveInit,
          //   ),
          // ),
          const Icon(
            Icons.school,
            size: 150,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                LoginFields(
                  controlTeddy: controlTeddy,
                  formKey: formKey,
                ),
                const SizedBox(
                  height: 10,
                ),
                CheckboxListTile(
                  value: autoLogin,
                  title: const Text("Enable Auto login?"),
                  onChanged: (bool? value) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    setState(() {
                      autoLogin = value ?? false;
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                LoginButton(
                  controlTeddy: controlTeddy,
                  formKey: formKey,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "By logging in, you accept our Terms and Conditions and Privacy Policy",
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton(
      {Key? key, required this.controlTeddy, required this.formKey})
      : super(key: key);

  final ControlTeddy controlTeddy;

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              // Keeping track of captcha loading to disable enable button
              bool captchaLoading = true;
              Uint8List? captchaImageBytes = ref.watch(
                  userLoginStateProvider.select((value) => value.captchaImage));
              if (captchaImageBytes != null && captchaImageBytes.isNotEmpty) {
                captchaLoading = false;
              } else {
                captchaLoading = true;
              }

              LoginStatus loginStatus = ref.watch(
                  userLoginStateProvider.select((value) => value.loginStatus));

              ref.listen(
                  userLoginStateProvider.select((value) => value.loginStatus),
                  (previous, next) {
                if (next == LoginStatus.loggedIn) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  });
                }
                if (previous != next) {
                  final LoginStatus loginStatus =
                      ref.read(userLoginStateProvider).loginStatus;

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();

                  ScaffoldMessenger.of(context).showSnackBar(
                      loginSnackBar(status: loginStatus, context: context));
                }
              });

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                onPressed: !captchaLoading
                    ? () {
                        if (formKey.currentState!.validate()) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          controlTeddy.submitPassword();

                          ref.read(userLoginStateProvider).updateLoginStatus(
                              loginStatus: LoginStatus.processing);

                          final VTOPActions readVTOPActionsProviderValue =
                              ref.read(vtopActionsProvider);

                          readVTOPActionsProviderValue.performSignIn(
                              context: context);
                        }
                      }
                    : null,
                child: Center(
                  child: loginStatus != LoginStatus.processing
                      ? const Text('Login')
                      : SpinKitThreeBounce(
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 24,
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

SnackBar loginSnackBar(
        {required LoginStatus status, required BuildContext context}) =>
    SnackBar(
      content: status == LoginStatus.wrongCaptcha
          ? Text(
              '🤯 Captcha was invalid! Please try again.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            )
          : status == LoginStatus.wrongPassword
              ? Text(
                  '🤯 Password was wrong! Please try again.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                )
              : status == LoginStatus.wrongUserId
                  ? Text(
                      '🤯 User Id was wrong! Please try again.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    )
                  : status == LoginStatus.maxAttemptsError
                      ? Text(
                          '⚠️Max fail attempts reached! Please use forget password.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                        )
                      : status == LoginStatus.unknownError
                          ? Text(
                              '⚠️Unknown error! Please try again latter or use official VTOP for now.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                            )
                          : status == LoginStatus.loggedIn
                              ? const Text('😀 Successfully logged in!')
                              : status == LoginStatus.processing
                                  ? const Text(
                                      '🤔 Processing login! Please wait.')
                                  : const Text('🤔🤔🤔'),
      backgroundColor: status == LoginStatus.wrongCaptcha
          ? Theme.of(context).colorScheme.errorContainer
          : status == LoginStatus.wrongPassword
              ? Theme.of(context).colorScheme.errorContainer
              : status == LoginStatus.wrongUserId
                  ? Theme.of(context).colorScheme.errorContainer
                  : status == LoginStatus.maxAttemptsError
                      ? Theme.of(context).colorScheme.errorContainer
                      : status == LoginStatus.unknownError
                          ? Theme.of(context).colorScheme.errorContainer
                          : status == LoginStatus.loggedIn
                              ? null
                              : status == LoginStatus.processing
                                  ? null
                                  : null,
      duration: status == LoginStatus.wrongCaptcha
          ? const Duration(days: 365)
          : status == LoginStatus.wrongPassword
              ? const Duration(days: 365)
              : status == LoginStatus.wrongUserId
                  ? const Duration(days: 365)
                  : status == LoginStatus.maxAttemptsError
                      ? const Duration(days: 365)
                      : status == LoginStatus.unknownError
                          ? const Duration(days: 365)
                          : status == LoginStatus.loggedIn
                              ? const Duration(seconds: 4)
                              : status == LoginStatus.processing
                                  ? const Duration(seconds: 4)
                                  : const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Ok',
        onPressed: () {},
      ),
    );

class LoginFields extends StatelessWidget {
  const LoginFields(
      {Key? key, required this.controlTeddy, required this.formKey})
      : super(key: key);

  final ControlTeddy controlTeddy;

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        String solvedCaptcha = ref.watch(
            userLoginStateProvider.select((value) => value.solvedCaptcha));

        return Form(
          key: formKey,
          child: Column(
            children: [
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return TrackingTextInput(
                    prefixIcon: const Icon(Icons.badge),
                    helperText: 'Ex:- 20BCEXXXXX',
                    labelText: 'UserID',
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      FilteringTextInputFormatter.allow(RegExp("[0-9A-Z]")),
                    ],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter UserID';
                      }
                      return null;
                    },
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    isObscured: false,
                    enableSuggestions: true,
                    autocorrect: false,
                    enabled: true,
                    readOnly: false,
                    onCaretMoved: (
                        {Offset? globalCaretPosition, Size? textFieldSize}) {
                      controlTeddy.lookAt(
                          textFieldSize: textFieldSize,
                          caret: globalCaretPosition);
                    },
                    onTextChanged: (String value) {
                      ref.read(userLoginStateProvider).setUserID(userID: value);
                      // print(value);
                    },
                  );
                },
              ),
              ForgotDetailButtons(
                label: "Forgot UserID?",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotUserID(),
                    ),
                  ).then((value) {
                    final HeadlessWebView readHeadlessWebViewProviderValue =
                        ref.read(headlessWebViewProvider);
                    readHeadlessWebViewProviderValue
                        .settingSomeVarsBeforeWebViewRestart();
                    readHeadlessWebViewProviderValue.runHeadlessInAppWebView();
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return TrackingTextInput(
                    prefixIcon: const Icon(Icons.password),
                    helperText: 'Ex:- password123',
                    labelText: 'VTOP Password',
                    inputFormatters: [],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter VTOP password';
                      }
                      return null;
                    },
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    isObscured: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    enabled: true,
                    readOnly: false,
                    onCaretMoved: (
                        {Offset? globalCaretPosition, Size? textFieldSize}) {
                      controlTeddy.coverEyes(
                          cover: globalCaretPosition != null);
                      controlTeddy.lookAt(
                          textFieldSize: textFieldSize, caret: null);
                    },
                    onTextChanged: (String value) {
                      controlTeddy.password = value;
                      ref
                          .read(userLoginStateProvider)
                          .setPassword(password: value);
                    },
                  );
                },
              ),
              ForgotDetailButtons(
                label: "Forgot Password?",
                onPressed: () {},
              ),
              const SizedBox(
                height: 10,
              ),
              const CaptchaSection(),
              const SizedBox(
                height: 10,
              ),
              TrackingTextInput(
                prefixIcon: const Icon(Icons.smart_toy),
                helperText: '🤖🤖🤖',
                labelText: 'Captcha',
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp("[0-9A-Z]")),
                ],
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter captcha';
                  }
                  return null;
                },
                autoValidateMode: AutovalidateMode.onUserInteraction,
                isObscured: false,
                enableSuggestions: false,
                autocorrect: false,
                enabled: true,
                readOnly: false,
                onCaretMoved: (
                    {Offset? globalCaretPosition, Size? textFieldSize}) {
                  controlTeddy.coverEyes(cover: globalCaretPosition != null);
                  controlTeddy.lookAt(
                      textFieldSize: textFieldSize, caret: null);
                },
                onTextChanged: (String value) {
                  ref.read(userLoginStateProvider).setCaptcha(captcha: value);
                },
                preFilledValue: solvedCaptcha,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ForgotDetailButtons extends StatelessWidget {
  const ForgotDetailButtons({Key? key, this.onPressed, required this.label})
      : super(key: key);

  final void Function()? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // Keeping track of captcha loading to disable enable button
        bool captchaLoading = true;
        Uint8List? captchaImageBytes = ref.watch(
            userLoginStateProvider.select((value) => value.captchaImage));
        if (captchaImageBytes != null && captchaImageBytes.isNotEmpty) {
          captchaLoading = false;
        } else {
          captchaLoading = true;
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                // minimumSize: Size(0, 0),
              ),
              onPressed: !captchaLoading ? onPressed : null,
              child: Text(label),
            ),
          ],
        );
      },
    );
  }
}

class CaptchaSection extends StatelessWidget {
  const CaptchaSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CaptchaImage(),
        SizedBox(
          width: 10,
        ),
        CaptchaIconButton(),
      ],
    );
  }
}

class CaptchaIconButton extends StatelessWidget {
  const CaptchaIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // Keeping track of captcha loading to disable enable button
        bool captchaLoading = true;
        Uint8List? captchaImageBytes = ref.watch(
            userLoginStateProvider.select((value) => value.captchaImage));
        if (captchaImageBytes != null && captchaImageBytes.isNotEmpty) {
          captchaLoading = false;
        } else {
          captchaLoading = true;
        }

        return IconButton(
            onPressed: !captchaLoading
                ? () {
                    final UserLoginState readUserLoginStateProviderValue =
                        ref.read(userLoginStateProvider);

                    readUserLoginStateProviderValue.updateCaptchaImage(
                        bytes: Uint8List.fromList([]));

                    final VTOPActions readVTOPActionsProviderValue =
                        ref.read(vtopActionsProvider);

                    readVTOPActionsProviderValue.performCaptchaRefresh(
                        context: context);

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  }
                : null,
            icon: const Icon(Icons.refresh));
      },
    );
  }
}

class CaptchaImage extends StatelessWidget {
  const CaptchaImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        Image? image;

        bool captchaLoading = true;

        Uint8List? captchaImageBytes = ref.watch(
            userLoginStateProvider.select((value) => value.captchaImage));

        if (captchaImageBytes != null && captchaImageBytes.isNotEmpty) {
          image = Image.memory(
            captchaImageBytes,
            fit: BoxFit.cover,
          );

          captchaLoading = false;
        } else {
          captchaLoading = true;
        }

        return Container(
          clipBehavior: Clip.antiAlias,
          width: 180,
          height: 45,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Stack(
            children: [
              Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surfaceVariant,
                highlightColor: Theme.of(context).colorScheme.primary,
                enabled: captchaLoading,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
              image ?? const SizedBox(),
            ],
          ),
        );
      },
    );
  }
}
