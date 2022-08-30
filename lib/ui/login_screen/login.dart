import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mini_vtop/state/user_login_state.dart';
import 'package:mini_vtop/state/vtop_actions.dart';
import 'package:mini_vtop/ui/login_screen/components/control_teddy.dart';
import 'package:mini_vtop/ui/login_screen/components/tracking_text_input.dart';
import 'package:shimmer/shimmer.dart';

import '../../state/providers.dart';
import '../home_screen/home_screen.dart';
import 'components/upper_case_text_formatter.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
            size: 200,
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
              bool processingLogin = ref.watch(userLoginStateProvider
                  .select((value) => value.processingLogin));

              ref.listen(
                  userLoginStateProvider.select((value) => value.userLoggedIn),
                  (previous, next) {
                if (previous == false && next == true) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  });
                }
                ref
                    .read(userLoginStateProvider)
                    .updateLoginProgress(loginProgress: false);
              });

              ref.listen(
                  userLoginStateProvider.select(
                      (value) => value.processingLogin), (previous, next) {
                processingLogin = next;
              });

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    controlTeddy.submitPassword();

                    ref
                        .read(userLoginStateProvider)
                        .updateLoginProgress(loginProgress: true);

                    final VTOPActions readVTOPActionsProviderValue =
                        ref.read(vtopActionsProvider);

                    readVTOPActionsProviderValue.performSignIn(
                        context: context);
                  }
                },
                child: Center(
                  child: !processingLogin
                      ? Text('Login')
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
                    helperText: 'Ex:- 20BCEXXXXX',
                    labelText: 'Username / Registration No.',
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      FilteringTextInputFormatter.allow(RegExp("[0-9A-Z]")),
                    ],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter registration no.';
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
                      ref
                          .read(userLoginStateProvider)
                          .setRegistrationNumber(registrationNumber: value);
                      // print(value);
                    },
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return TrackingTextInput(
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
              const SizedBox(
                height: 10,
              ),
              const CaptchaSection(),
              const SizedBox(
                height: 10,
              ),
              TrackingTextInput(
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

class CaptchaSection extends StatelessWidget {
  const CaptchaSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CaptchaImage(),
        const SizedBox(
          width: 10,
        ),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return IconButton(
                onPressed: () {
                  final UserLoginState readUserLoginStateProviderValue =
                      ref.read(userLoginStateProvider);

                  readUserLoginStateProviderValue.updateCaptchaImage(
                      bytes: Uint8List.fromList([]));

                  final VTOPActions readVTOPActionsProviderValue =
                      ref.read(vtopActionsProvider);

                  readVTOPActionsProviderValue.performCaptchaRefresh(
                      context: context);
                },
                icon: const Icon(Icons.refresh));
          },
        ),
      ],
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

        bool imageLoading = true;

        Uint8List? captchaImageBytes = ref.watch(
            userLoginStateProvider.select((value) => value.captchaImage));

        if (captchaImageBytes != null && captchaImageBytes.isNotEmpty) {
          image = Image.memory(
            captchaImageBytes,
            fit: BoxFit.cover,
          );

          Future.delayed(const Duration(milliseconds: 1000), () {
            imageLoading = false;
          });
        } else {
          imageLoading = true;
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
                enabled: imageLoading,
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
