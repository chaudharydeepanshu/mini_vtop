import 'package:flutter/material.dart';

class StudentProfileAllView extends StatefulWidget {
  static const String routeName = '/studentProfileAllView';

  const StudentProfileAllView({
    Key? key,
    this.arguments,
  }) : super(key: key);

  final StudentProfileAllViewArguments? arguments;

  @override
  _StudentProfileAllViewState createState() => _StudentProfileAllViewState();
}

class _StudentProfileAllViewState extends State<StudentProfileAllView> {
  @override
  void dispose() {
    super.dispose();
    widget.arguments?.onShowStudentProfileAllViewDispose?.call(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Student Profile All View",
        ),
      ),
      body: const Material(
        child: Text("StudentProfileAllView"),
      ),
    );
  }
}

class StudentProfileAllViewArguments {
  String? currentStatus;
  ValueChanged<bool>? onShowStudentProfileAllViewDispose;
  // String userEnteredUname;
  // String userEnteredPasswd;
  // HeadlessInAppWebView headlessWebView;
  // Image? image;

  StudentProfileAllViewArguments({
    required this.currentStatus,
    required this.onShowStudentProfileAllViewDispose,
    // required this.userEnteredUname,
    // required this.userEnteredPasswd,
    // required this.headlessWebView,
    // required this.image,
  });
}
