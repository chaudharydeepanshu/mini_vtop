import 'package:flutter/material.dart';
import 'package:mini_vtop/ui/components/linear_completion_meter.dart';

class Attendance extends StatelessWidget {
  const Attendance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        centerTitle: true,
      ),
      body: ListView(
        children: const [
          AttendanceCard(),
          SizedBox(
            height: 8,
          ),
          AttendanceCard(),
          SizedBox(
            height: 8,
          ),
          AttendanceCard(),
          SizedBox(
            height: 8,
          ),
          AttendanceCard(),
          SizedBox(
            height: 8,
          ),
          AttendanceCard(),
          SizedBox(
            height: 8,
          ),
          AttendanceCard(),
          SizedBox(
            height: 8,
          ),
          AttendanceCard(),
          SizedBox(
            height: 8,
          ),
          AttendanceCard(),
          SizedBox(
            height: 8,
          ),
          AttendanceCard(),
          SizedBox(
            height: 8,
          ),
          AttendanceCard(),
        ],
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Maths",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Expanded(
                                child: LinearCompletionMeter(
                                  progressInPercent: 60,
                                  showProgressLabel: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(
              width: 0,
            ),
            InkWell(
              onTap: () {},
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_forward,
                        size: 18,
                      ),
                      Text(
                        "More Detail",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
