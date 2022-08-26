import 'package:flutter/material.dart';
import 'package:mini_vtop/ui/header_section_screen/components/gpa_section.dart';

class Academics extends StatelessWidget {
  const Academics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Academics"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          CGPASection(),
        ],
      ),
    );
  }
}
