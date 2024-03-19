import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/models/student_attendance_model.dart';
import 'package:minivtop/models/student_timetable_model.dart';
import 'package:minivtop/state/vtop_controller_state.dart';
import 'package:minivtop/ui/components/linear_completion_meter.dart';

import '../../../shared_preferences/preferences.dart';
import '../../../state/connection_state.dart';
import '../../../state/providers.dart';
import '../../../state/user_login_state.dart';
import '../../../state/vtop_actions.dart';
import '../../../state/vtop_data_state.dart';
import '../../components/cached_mode_warning.dart';
import '../../components/empty_content_indicator.dart';
import '../../components/page_body_indicators.dart';
import '../components/info_line.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  @override
  void initState() {
    final VTOPPageStatus studentAttendancePageStatus =
        ref.read(vtopActionsProvider).studentAttendancePageStatus;

    final VTOPActions readVTOPActionsProviderValue =
        ref.read(vtopActionsProvider);

    if (studentAttendancePageStatus != VTOPPageStatus.loaded) {
      readVTOPActionsProviderValue.studentAttendanceAction();
    } else {
      final VTOPData readVTOPDataProviderValue = ref.read(vtopDataProvider);

      final StudentAttendanceModel? studentAttendance =
          ref.read(vtopDataProvider.select((value) => value.studentAttendance));

      final List<SemesterModel>? semesterDropDownDetails =
          studentAttendance?.semesterDropDownDetails;

      String? selectedSemesterCode = semesterDropDownDetails
          ?.firstWhereOrNull((element) => element.isSelected)
          ?.semesterCode;

      final VTOPControllerState readVTOPControllerStateProviderValue =
          ref.read(vtopControllerStateProvider);

      String defaultSemesterCode =
          readVTOPControllerStateProviderValue.vtopController.attendanceID;

      final Preferences readPreferencesProviderValue =
          ref.read(preferencesProvider);

      String? attendanceHTMLDoc =
          readPreferencesProviderValue.attendanceHTMLDoc;

      if (selectedSemesterCode != null &&
          selectedSemesterCode != defaultSemesterCode &&
          attendanceHTMLDoc != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await readVTOPDataProviderValue.setStudentAttendance(
              studentAttendanceDocument: attendanceHTMLDoc,
              selectedSemesterCode: defaultSemesterCode);
        });
      }
    }

    super.initState();
  }

  refreshData(WidgetRef ref) {
    final VTOPActions readVTOPActionsProviderValue =
        ref.read(vtopActionsProvider);
    readVTOPActionsProviderValue.updateOfflineModeStatus(mode: false);
    readVTOPActionsProviderValue.studentAttendanceAction();
    readVTOPActionsProviderValue.updateStudentAttendancePageStatus(
        status: VTOPPageStatus.processing);
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

            ref.listen<ConnectionStatusState>(connectionStatusStateProvider,
                (ConnectionStatusState? previous, ConnectionStatusState next) {
              if (next.connectionStatus == ConnectionStatus.connected &&
                  ref.read(userLoginStateProvider).loginResponseStatus ==
                      LoginResponseStatus.loggedIn) {
                refreshData(ref);
              }
            });

            return studentAttendancePageStatus == VTOPPageStatus.loaded ||
                    enableOfflineMode
                ? const Column(
                    children: [
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
          refreshData(ref);
        },
      ),
    );
  }
}

class AttendanceBody extends StatelessWidget {
  const AttendanceBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final StudentAttendanceModel? studentAttendance = ref
            .watch(vtopDataProvider.select((value) => value.studentAttendance));

        final bool enableOfflineMode = ref.watch(
            vtopActionsProvider.select((value) => value.enableOfflineMode));

        if (studentAttendance != null) {
          final String attendanceHTMLDoc = studentAttendance.attendanceHTMLDoc;

          final List<SemesterModel> semesterDropDownDetails =
              studentAttendance.semesterDropDownDetails;

          final List<SubjectAttendanceDetailModel> subjectsAttendanceDetails =
              studentAttendance.subjectsAttendanceDetails;

          String? selectedSemesterCode = semesterDropDownDetails
              .firstWhereOrNull((element) => element.isSelected)
              ?.semesterCode;

          final VTOPControllerState watchVTOPControllerStateProviderValue =
              ref.watch(vtopControllerStateProvider);

          String defaultTimeTableSemesterCode =
              watchVTOPControllerStateProviderValue.vtopController.timeTableID;

          String defaultAttendanceSemesterCode =
              watchVTOPControllerStateProviderValue.vtopController.attendanceID;

          return Column(
            children: [
              selectedSemesterCode != null && enableOfflineMode == false
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onLongPress: () {
                              final Preferences readPreferencesProviderValue =
                                  ref.read(preferencesProvider);
                              readPreferencesProviderValue.persistVTOPController(
                                  '{"attendanceID":"$selectedSemesterCode", "timeTableID":"$defaultTimeTableSemesterCode"}');
                              watchVTOPControllerStateProviderValue.init();
                              readPreferencesProviderValue
                                  .persistAttendanceHTMLDoc(attendanceHTMLDoc);
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Selected semester set as default!'),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Semester - ",
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                Expanded(
                                  child: DropdownButton(
                                    isExpanded: true,
                                    menuMaxHeight: 500,
                                    items: List.generate(
                                        semesterDropDownDetails.length,
                                        (index) {
                                      bool isSelected = selectedSemesterCode ==
                                          semesterDropDownDetails[index]
                                              .semesterCode;
                                      bool isDefault =
                                          defaultAttendanceSemesterCode ==
                                              semesterDropDownDetails[index]
                                                  .semesterCode;

                                      return DropdownMenuItem(
                                        value: semesterDropDownDetails[index]
                                            .semesterCode,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                semesterDropDownDetails[index]
                                                    .semesterName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                        decoration: isSelected
                                                            ? TextDecoration
                                                                .underline
                                                            : null,
                                                        color: isSelected
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : null),
                                              ),
                                            ),
                                            isDefault
                                                ? Chip(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    labelPadding:
                                                        EdgeInsets.zero,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    label: Text(
                                                      "Default",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelSmall,
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      );
                                    }),
                                    value: selectedSemesterCode,
                                    onChanged: (String? value) {
                                      if (semesterDropDownDetails
                                              .firstWhere((element) =>
                                                  element.isSelected)
                                              .semesterCode !=
                                          value) {
                                        final VTOPActions
                                            readVTOPActionsProviderValue =
                                            ref.read(vtopActionsProvider);
                                        readVTOPActionsProviderValue
                                            .studentAttendanceViewAction(
                                                attendanceID: value);
                                      }
                                    },
                                    selectedItemBuilder:
                                        (BuildContext context) {
                                      return List.generate(
                                          semesterDropDownDetails.length,
                                          (index) {
                                        return DropdownMenuItem(
                                          value: semesterDropDownDetails[index]
                                              .semesterCode,
                                          child: Text(
                                            semesterDropDownDetails[index]
                                                .semesterName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Long press on selector to set selected semester as default",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    )
                  : const SizedBox(),
              subjectsAttendanceDetails.isNotEmpty
                  ? Expanded(
                      child: ListView.separated(
                        itemCount: subjectsAttendanceDetails.length,
                        itemBuilder: (BuildContext context, int index) {
                          final SubjectAttendanceDetailModel
                              subjectAttendanceDetail =
                              subjectsAttendanceDetails[index];
                          return AttendanceCard(
                              subjectAttendanceDetail: subjectAttendanceDetail);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 8);
                        },
                      ),
                    )
                  : const Center(child: Text("No attendance data available")),
            ],
          );
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
  const AttendanceCard({super.key, required this.subjectAttendanceDetail});

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
    // (attendedClasses / totalClasses) * 100;

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
              const Row(
                children: [
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
