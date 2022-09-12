import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/models/student_attendance_model.dart';
import 'package:minivtop/ui/components/linear_completion_meter.dart';

import '../../../shared_preferences/preferences.dart';
import '../../../state/providers.dart';
import '../../../state/vtop_actions.dart';
import '../../../state/vtop_data_state.dart';
import '../../components/cached_mode_warning.dart';
import '../../components/empty_content_indicator.dart';
import '../../components/page_body_indicators.dart';
import '../components/info_line.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  @override
  void initState() {
    final VTOPPageStatus studentAttendancePageStatus =
        ref.read(vtopActionsProvider).studentAttendancePageStatus;

    if (studentAttendancePageStatus != VTOPPageStatus.loaded) {
      final VTOPActions readVTOPActionsProviderValue =
          ref.read(vtopActionsProvider);
      readVTOPActionsProviderValue.studentAttendanceAction();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final VTOPPageStatus studentAttendancePageStatus = ref.watch(
                vtopActionsProvider
                    .select((value) => value.studentAttendancePageStatus));

            final bool enableOfflineMode = ref.watch(
                vtopActionsProvider.select((value) => value.enableOfflineMode));

            if (enableOfflineMode == true) {
              final Preferences readPreferencesProviderValue =
                  ref.read(preferencesProvider);
              String? oldHTMLDoc =
                  readPreferencesProviderValue.attendanceHTMLDoc;
              final VTOPData readVTOPDataProviderValue =
                  ref.read(vtopDataProvider);
              if (oldHTMLDoc != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  readVTOPDataProviderValue.setStudentAttendance(
                      studentAttendanceDocument: oldHTMLDoc);
                });
              }
            }

            return studentAttendancePageStatus == VTOPPageStatus.loaded ||
                    enableOfflineMode
                ? Column(
                    children: const [
                      CachedModeWarning(),
                      Expanded(child: AttendanceBody()),
                    ],
                  )
                : PageBodyIndicators(
                    pageStatus: studentAttendancePageStatus,
                    location: Location.afterHomeScreen);
          },
        ),
        onRefresh: () async {
          final VTOPActions readVTOPActionsProviderValue =
              ref.read(vtopActionsProvider);
          readVTOPActionsProviderValue.updateOfflineModeStatus(mode: false);
          readVTOPActionsProviderValue.studentTimeTableAction();
          readVTOPActionsProviderValue.updateStudentTimeTablePageStatus(
              status: VTOPPageStatus.processing);
        },
      ),
    );
  }
}

class AttendanceBody extends StatelessWidget {
  const AttendanceBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final StudentAttendanceModel? studentAttendance = ref
            .watch(vtopDataProvider.select((value) => value.studentAttendance));

        if (studentAttendance != null) {
          final List<SubjectAttendanceDetailModel> subjectsAttendanceDetails =
              studentAttendance.subjectsAttendanceDetails;

          return subjectsAttendanceDetails.isNotEmpty
              ? ListView.separated(
                  itemCount: subjectsAttendanceDetails.length,
                  itemBuilder: (BuildContext context, int index) {
                    final SubjectAttendanceDetailModel subjectAttendanceDetail =
                        subjectsAttendanceDetails[index];
                    return AttendanceCard(
                        subjectAttendanceDetail: subjectAttendanceDetail);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 8);
                  },
                )
              : const Center(child: Text("No attendance data available"));
        } else {
          return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                child: const EmptyContentIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}

class AttendanceCard extends StatefulWidget {
  const AttendanceCard({Key? key, required this.subjectAttendanceDetail})
      : super(key: key);

  final SubjectAttendanceDetailModel subjectAttendanceDetail;

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String subjectName = widget.subjectAttendanceDetail.subjectName;
    final String subjectCode = widget.subjectAttendanceDetail.subjectCode;
    final String subjectType = widget.subjectAttendanceDetail.subjectType;
    final String subjectSlot = widget.subjectAttendanceDetail.subjectSlot;
    final String facultyCode = widget.subjectAttendanceDetail.facultyCode;
    final String facultyName = widget.subjectAttendanceDetail.facultyName;
    final int attendedClasses = widget.subjectAttendanceDetail.attendedClasses;
    final int totalClasses = widget.subjectAttendanceDetail.totalClasses;
    final double percentOfAttendance =
        widget.subjectAttendanceDetail.percentOfAttendance;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(horizontal: isExpanded ? 0 : 16.0),
      elevation: isExpanded ? 0 : Theme.of(context).cardTheme.elevation,
      shape: RoundedRectangleBorder(
        //   side: BorderSide(
        //     color: Theme.of(context).colorScheme.outline,
        //   ),
        borderRadius: BorderRadius.all(Radius.circular(isExpanded ? 0 : 12)),
      ),
      child: ExpansionTile(
        trailing: null,
        tilePadding: EdgeInsets.zero,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        expandedAlignment: Alignment.topLeft,
        onExpansionChanged: (bool value) {
          setState(() {
            isExpanded = value;
          });
        },
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subjectName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                children: const [
                  Expanded(flex: 5, child: Divider()),
                  Expanded(flex: 5, child: SizedBox()),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: LinearCompletionMeter(
                            progressInPercent: percentOfAttendance,
                            showProgressLabel: true,
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
                                "$attendedClasses",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                "/",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              Text(
                                "$totalClasses",
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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Expanded(
              //       child: Row(
              //         crossAxisAlignment: CrossAxisAlignment.end,
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Expanded(
              //             child: LinearCompletionMeter(
              //               progressInPercent: percentOfAttendance,
              //               showProgressLabel: true,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
        children: <Widget>[
          const Divider(
              // height: 0,
              ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                InfoLine(detailName: "Sub. Code", detail: subjectCode),
                InfoLine(detailName: "Class Type", detail: subjectType),
                InfoLine(detailName: "Slot", detail: subjectSlot),
                InfoLine(detailName: "Faculty Code", detail: facultyCode),
                InfoLine(detailName: "Faculty", detail: facultyName),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
