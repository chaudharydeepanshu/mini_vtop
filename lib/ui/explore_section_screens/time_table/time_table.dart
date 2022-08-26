import 'package:flutter/material.dart';

class TimeTable extends StatelessWidget {
  const TimeTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time-Table"),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(),
      ),
    );
  }
}
