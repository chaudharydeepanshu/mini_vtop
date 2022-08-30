import 'package:flutter/material.dart';
import 'package:mini_vtop/ui/header_section_screen/components/attendance_section.dart';
import 'package:mini_vtop/ui/header_section_screen/components/gpa_section.dart';

class QuickGlance extends StatelessWidget {
  const QuickGlance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quick Glance"),
        centerTitle: true,
      ),
      body: ListView(
        children: const [
          CGPASection(),
          SizedBox(
            height: 16,
          ),
          AttendanceSection(),
          SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}