import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_vtop/ui/login_screen/components/control_teddy.dart';
import 'package:mini_vtop/ui/login_screen/components/tracking_text_input.dart';
import 'package:shimmer/shimmer.dart';

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

  @override
  void initState() {
    controlTeddy = ControlTeddy();
    super.initState();
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
                  onRegistrationNumber: (String value) {
                    registrationNumber = value;
                  },
                  onPassword: (String value) {
                    password = value;
                  },
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
  const LoginButton({Key? key, required this.controlTeddy}) : super(key: key);

  final ControlTeddy controlTeddy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              controlTeddy.submitPassword();
            },
            child: Center(
              child: const Text('Login'),
            ),
          ),
        ),
      ],
    );
  }
}

class LoginFields extends StatelessWidget {
  const LoginFields(
      {Key? key,
      required this.onRegistrationNumber,
      required this.onPassword,
      required this.controlTeddy})
      : super(key: key);

  final ValueChanged<String> onRegistrationNumber;
  final ValueChanged<String> onPassword;
  final ControlTeddy controlTeddy;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TrackingTextInput(
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
            onCaretMoved: ({Offset? globalCaretPosition, Size? textFieldSize}) {
              controlTeddy.lookAt(
                  textFieldSize: textFieldSize, caret: globalCaretPosition);
            },
            onTextChanged: (String value) {
              onRegistrationNumber.call(value);
              // print(value);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          TrackingTextInput(
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
            onCaretMoved: ({Offset? globalCaretPosition, Size? textFieldSize}) {
              controlTeddy.coverEyes(cover: globalCaretPosition != null);
              controlTeddy.lookAt(textFieldSize: textFieldSize, caret: null);
            },
            onTextChanged: (String value) {
              controlTeddy.password = value;
              onPassword.call(value);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          const CaptchaImage(),
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
          ),
        ],
      ),
    );
  }
}

class CaptchaImage extends StatefulWidget {
  const CaptchaImage({super.key});

  @override
  State<CaptchaImage> createState() => _CaptchaImageState();
}

class _CaptchaImageState extends State<CaptchaImage> {
  Image image = Image.network(
    'https://lh3.googleusercontent.com/drive-viewer/AJc5JmQhDPCm2QQMMUp-RLiJzFHsRu_PDc4pS-b9ihSXbOyVwjYjP6Ee6tKgjplTriedJvVmojOSGQY=w1920-h904',
    fit: BoxFit.cover,
  );

  bool imageLoading = true;

  @override
  void initState() {
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool syncCall) {
      setState(() {
        imageLoading = false;
      });

      // completer.complete();
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          Image.network(
            'https://lh3.googleusercontent.com/drive-viewer/AJc5JmQhDPCm2QQMMUp-RLiJzFHsRu_PDc4pS-b9ihSXbOyVwjYjP6Ee6tKgjplTriedJvVmojOSGQY=w1920-h904',
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}

// class CaptchaImage extends StatelessWidget {
//   const CaptchaImage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//
//     Image image = Image.network(
//         );
//
//     image.image.resolve(ImageConfiguration())
//         .addListener(ImageStreamListener((ImageInfo info, bool syncCall) {
//
// // DO SOMETHING HERE
//
//       completer.complete();
//
//     });
//
//     return Container(
//       child: image,
//     );
//   }
// }
