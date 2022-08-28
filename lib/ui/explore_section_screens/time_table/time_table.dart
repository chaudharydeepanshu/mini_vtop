import 'package:clean_calendar/clean_calendar.dart';
import 'package:flutter/material.dart';
import 'package:mini_vtop/ui/components/linear_completion_meter.dart';

class TimeTable extends StatelessWidget {
  const TimeTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time-Table"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Ink(
            color: Theme.of(context).colorScheme.onInverseSurface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CleanCalendar(
                datePickerCalendarView: DatePickerCalendarView.weekView,
                selectedDates: [
                  DateTime.now(),
                  DateTime(2022, 8, 9),
                  DateTime(2022, 8, 11),
                ],
                dateSelectionMode: DatePickerSelectionMode.single,
                onSelectedDates: (List<DateTime> selectedDates) {
                  // Called every time dates are selected or deselected.
                  print(selectedDates);
                },
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: ListView(
              children: const [
                TimeTableCard(),
                SizedBox(
                  height: 8,
                ),
                TimeTableCard(),
                SizedBox(
                  height: 8,
                ),
                TimeTableCard(),
                SizedBox(
                  height: 8,
                ),
                TimeTableCard(),
                SizedBox(
                  height: 8,
                ),
                TimeTableCard(),
                SizedBox(
                  height: 8,
                ),
                TimeTableCard(),
                SizedBox(
                  height: 8,
                ),
                TimeTableCard(),
                SizedBox(
                  height: 8,
                ),
                TimeTableCard(),
                SizedBox(
                  height: 8,
                ),
                TimeTableCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimeTableCard extends StatelessWidget {
  const TimeTableCard({Key? key}) : super(key: key);

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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Maths",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              "8:15 am - 9:15 am",
              style: Theme.of(context).textTheme.caption,
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        flex: 5,
                        child: LinearCompletionMeter(
                          progressInPercent: 60,
                          showProgressLabel: false,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Room # ",
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Text(
                              "4563 - B",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
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
    );
  }
}
