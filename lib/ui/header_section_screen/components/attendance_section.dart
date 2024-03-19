import 'package:flutter/material.dart';
import 'package:minivtop/ui/components/linear_completion_meter.dart';

class AttendanceSection extends StatelessWidget {
  const AttendanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Attendance",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return const AttendanceForSubject(
                        subjectName: 'Maths',
                        subjectAttendanceInPercent: 72,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                    itemCount: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AttendanceForSubject extends StatelessWidget {
  const AttendanceForSubject(
      {super.key,
      required this.subjectName,
      required this.subjectAttendanceInPercent});

  final String subjectName;
  final double subjectAttendanceInPercent;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              subjectName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 10,
            child: LinearCompletionMeter(
              progressInPercent: subjectAttendanceInPercent,
              showProgressLabel: true,
            ),
          ),
        ],
      ),
    );
  }
}
