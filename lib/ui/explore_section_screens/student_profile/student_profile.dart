import 'package:flutter/material.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              children: const [
                DetailLine(
                  parameter1: 'Name',
                  parameter2: 'Deepanshu Chaudhary',
                ),
                Divider(),
                DetailLine(
                  parameter1: 'DOB',
                  parameter2: '00-Jan-0000',
                ),
                Divider(),
                DetailLine(
                  parameter1: 'Blood Group',
                  parameter2: 'X+',
                ),
                Divider(),
                DetailLine(
                  parameter1: 'Roll No.',
                  parameter2: '20BCE00000',
                ),
                Divider(),
                DetailLine(
                  parameter1: 'Application No.',
                  parameter2: '2020000000',
                ),
                Divider(),
                DetailLine(
                  parameter1: 'Program',
                  parameter2: 'BTECH',
                ),
                Divider(),
                DetailLine(
                  parameter1: 'Branch',
                  parameter2: 'Computer Science and Engineering',
                ),
                Divider(),
                DetailLine(
                  parameter1: 'School',
                  parameter2: 'School of Computing Sciences and Engineering',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailLine extends StatelessWidget {
  const DetailLine(
      {Key? key, required this.parameter1, required this.parameter2})
      : super(key: key);

  final String parameter1;
  final String parameter2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(
                parameter1,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const VerticalDivider(),
            Expanded(flex: 10, child: Text(parameter2)),
          ],
        ),
      ),
    );
  }
}
