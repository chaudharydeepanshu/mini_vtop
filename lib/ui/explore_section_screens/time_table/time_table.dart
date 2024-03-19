import 'package:clean_calendar/clean_calendar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/models/student_timetable_model.dart';
import 'package:minivtop/state/providers.dart';
import 'package:minivtop/state/vtop_actions.dart';
import 'package:minivtop/state/vtop_controller_state.dart';
import 'package:minivtop/ui/components/linear_completion_meter.dart';

import '../../../shared_preferences/preferences.dart';
import '../../../state/connection_state.dart';
import '../../../state/user_login_state.dart';
import '../../../state/vtop_data_state.dart';
import '../../components/cached_mode_warning.dart';
import '../../components/empty_content_indicator.dart';
import '../../components/page_body_indicators.dart';
import '../components/info_line.dart';

class TimeTablePage extends ConsumerStatefulWidget {
  const TimeTablePage({super.key});

  @override
  ConsumerState<TimeTablePage> createState() => _TimeTablePageState();
}

class _TimeTablePageState extends ConsumerState<TimeTablePage> {
  @override
  void initState() {
    final VTOPPageStatus studentTimeTablePageStatus =
        ref.read(vtopActionsProvider).studentTimeTablePageStatus;

    final VTOPActions readVTOPActionsProviderValue =
        ref.read(vtopActionsProvider);

    if (studentTimeTablePageStatus != VTOPPageStatus.loaded) {
      readVTOPActionsProviderValue.studentTimeTableAction();
    } else {
      final VTOPData readVTOPDataProviderValue = ref.read(vtopDataProvider);

      final StudentTimeTableModel? studentTimeTable =
          ref.read(vtopDataProvider.select((value) => value.studentTimeTable));

      final List<SemesterModel>? semesterDropDownDetails =
          studentTimeTable?.semesterDropDownDetails;

      String? selectedSemesterCode = semesterDropDownDetails
          ?.firstWhereOrNull((element) => element.isSelected)
          ?.semesterCode;

      final VTOPControllerState readVTOPControllerStateProviderValue =
          ref.read(vtopControllerStateProvider);

      String defaultSemesterCode =
          readVTOPControllerStateProviderValue.vtopController.timeTableID;

      final Preferences readPreferencesProviderValue =
          ref.read(preferencesProvider);

      String? timeTableHTMLDoc = readPreferencesProviderValue.timeTableHTMLDoc;

      if (selectedSemesterCode != null &&
          selectedSemesterCode != defaultSemesterCode &&
          timeTableHTMLDoc != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await readVTOPDataProviderValue.setStudentTimeTable(
              studentTimeTableDocument: timeTableHTMLDoc,
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
    readVTOPActionsProviderValue.studentTimeTableAction();
    readVTOPActionsProviderValue.updateStudentTimeTablePageStatus(
        status: VTOPPageStatus.processing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time-Table"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final VTOPPageStatus studentTimeTablePageStatus = ref.watch(
                vtopActionsProvider
                    .select((value) => value.studentTimeTablePageStatus));

            final bool enableOfflineMode = ref.watch(
                vtopActionsProvider.select((value) => value.enableOfflineMode));

            if (enableOfflineMode == true) {
              final Preferences readPreferencesProviderValue =
                  ref.read(preferencesProvider);
              String? oldHTMLDoc =
                  readPreferencesProviderValue.timeTableHTMLDoc;
              final VTOPData readVTOPDataProviderValue =
                  ref.read(vtopDataProvider);
              if (oldHTMLDoc != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  readVTOPDataProviderValue.setStudentTimeTable(
                      studentTimeTableDocument: oldHTMLDoc);
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

            return studentTimeTablePageStatus == VTOPPageStatus.loaded ||
                    enableOfflineMode
                ? const Column(
                    children: [
                      CachedModeWarning(),
                      Expanded(child: TimeTableBody()),
                    ],
                  )
                : PageBodyIndicators(
                    pageStatus: studentTimeTablePageStatus,
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

class TimeTableBody extends StatefulWidget {
  const TimeTableBody({super.key});

  @override
  State<TimeTableBody> createState() => _TimeTableBodyState();
}

class _TimeTableBodyState extends State<TimeTableBody> {
  late final DateTime currentDateTime;
  late DateTime selectedDateTime;

  @override
  void initState() {
    currentDateTime = DateTime.now();
    selectedDateTime = currentDateTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final StudentTimeTableModel? studentTimeTable = ref
            .watch(vtopDataProvider.select((value) => value.studentTimeTable));

        final bool enableOfflineMode = ref.watch(
            vtopActionsProvider.select((value) => value.enableOfflineMode));

        if (studentTimeTable != null) {
          final String timeTableHTMLDoc = studentTimeTable.timeTableHTMLDoc;

          final List<SemesterModel> semesterDropDownDetails =
              studentTimeTable.semesterDropDownDetails;
          final List<TimeTableClassDetailModel> timeTableClassesDetails =
              studentTimeTable.timeTableClassesDetails;
          final List<SubjectDetailModel> subjectsDetails =
              studentTimeTable.subjectsDetails;

          String? selectedSemesterCode = semesterDropDownDetails
              .firstWhereOrNull((element) => element.isSelected)
              ?.semesterCode;

          final VTOPControllerState watchVTOPControllerStateProviderValue =
              ref.watch(vtopControllerStateProvider);

          String defaultTimeTableSemesterCode =
              watchVTOPControllerStateProviderValue.vtopController.timeTableID;

          String defaultAttendanceSemesterCode =
              watchVTOPControllerStateProviderValue.vtopController.attendanceID;

          int selectedWeekDay = selectedDateTime.weekday;
          final List<TimeTableClassDetailModel>
              timeTableClassesDetailsForSelectedDay = timeTableClassesDetails
                  .where((element) => element.classWeekDay == selectedWeekDay)
                  .toList();

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
                                  '{"attendanceID":"$defaultAttendanceSemesterCode", "timeTableID":"$selectedSemesterCode"}');
                              watchVTOPControllerStateProviderValue.init();
                              readPreferencesProviderValue
                                  .persistTimeTableHTMLDoc(timeTableHTMLDoc);
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
                                          defaultTimeTableSemesterCode ==
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
                                            .studentTimeTableViewAction(
                                                timeTableID: value);
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
              Ink(
                color: Theme.of(context).colorScheme.onInverseSurface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CleanCalendar(
                    leadingTrailingDatesProperties: DatesProperties(
                        datesDecoration: DatesDecoration(
                            datesBackgroundColor: Colors.transparent,
                            datesTextColor:
                                Theme.of(context).colorScheme.onSurface,
                            datesTextStyle: const TextStyle(),
                            datesBorderColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                            datesBorderRadius: 12),
                        disable: false),
                    datePickerCalendarView: DatePickerCalendarView.weekView,
                    selectedDates: [
                      selectedDateTime,
                    ],
                    dateSelectionMode: DatePickerSelectionMode.singleOrMultiple,
                    onSelectedDates: (List<DateTime> selectedDates) {
                      // Called every time dates are selected or deselected.
                      setState(() {
                        selectedDateTime = selectedDates[0];
                        // print(selectedDates);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: timeTableClassesDetails.isNotEmpty
                    ? timeTableClassesDetailsForSelectedDay.isNotEmpty
                        ? ListView.separated(
                            itemCount:
                                timeTableClassesDetailsForSelectedDay.length,
                            itemBuilder: (BuildContext context, int index) {
                              final TimeTableClassDetailModel
                                  timeTableClassDetail =
                                  timeTableClassesDetailsForSelectedDay[index];
                              final SubjectDetailModel subjectDetail =
                                  subjectsDetails.firstWhere((element) =>
                                      element.subjectCode ==
                                      timeTableClassDetail.subjectCode);
                              return TimeTableCard(
                                  timeTableClassDetail: timeTableClassDetail,
                                  subjectDetail: subjectDetail,
                                  currentDateTime: currentDateTime,
                                  selectedDateTime: selectedDateTime);
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(height: 8);
                            },
                          )
                        : const Center(child: Text("No classes"))
                    : const Center(child: Text("No time-table available")),
              ),
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

class TimeTableCard extends StatefulWidget {
  const TimeTableCard(
      {super.key,
      required this.timeTableClassDetail,
      required this.subjectDetail,
      required this.currentDateTime,
      required this.selectedDateTime});

  final TimeTableClassDetailModel timeTableClassDetail;
  final SubjectDetailModel subjectDetail;
  final DateTime currentDateTime;
  final DateTime selectedDateTime;

  @override
  State<TimeTableCard> createState() => _TimeTableCardState();
}

class _TimeTableCardState extends State<TimeTableCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String subjectName = widget.subjectDetail.subjectName;
    final TimeOfDay classStartTime = widget.timeTableClassDetail.classStartTime;
    final TimeOfDay classEndTime = widget.timeTableClassDetail.classEndTime;
    final String subjectCode = widget.subjectDetail.subjectCode;
    final String subjectType = widget.subjectDetail.subjectType;
    final String classNumber = widget.subjectDetail.classNumber;
    final String subjectSlot = widget.subjectDetail.subjectSlot;
    final String facultyName = widget.subjectDetail.facultyName;
    final String classVenue = widget.subjectDetail.classVenue;
    final double progress;
    if (DateUtils.dateOnly(widget.currentDateTime)
        .isAfter(DateUtils.dateOnly(widget.selectedDateTime))) {
      progress = 100;
    } else if (DateUtils.dateOnly(widget.currentDateTime)
        .isAtSameMomentAs(DateUtils.dateOnly(widget.selectedDateTime))) {
      TimeOfDay currentDateTimeTimeOfDay =
          TimeOfDay.fromDateTime(widget.currentDateTime);
      double doubleClassStartTime = classStartTime.hour.toDouble() +
          (classStartTime.minute.toDouble() / 60);
      double doubleCurrentDateTimeTimeOfDay =
          currentDateTimeTimeOfDay.hour.toDouble() +
              (currentDateTimeTimeOfDay.minute.toDouble() / 60);
      double doubleClassEndTime =
          classEndTime.hour.toDouble() + (classEndTime.minute.toDouble() / 60);
      if (doubleCurrentDateTimeTimeOfDay > doubleClassStartTime) {
        double timeCompleted =
            doubleCurrentDateTimeTimeOfDay - doubleClassStartTime;
        double totalTime = doubleClassEndTime - doubleClassStartTime;
        double progressPercent = (timeCompleted / totalTime) * 100;
        progress = progressPercent;
      } else {
        progress = 0;
      }
    } else {
      progress = 0;
    }

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
              Text(
                "${classStartTime.format(context)} - ${classEndTime.format(context)}",
                style: Theme.of(context).textTheme.bodySmall,
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
                        Expanded(
                          flex: 5,
                          child: LinearCompletionMeter(
                            progressInPercent: progress,
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
                                "Venue # ",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                classVenue,
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
                InfoLine(detailName: "Class No.", detail: classNumber),
                InfoLine(detailName: "Slot", detail: subjectSlot),
                InfoLine(detailName: "Faculty", detail: facultyName),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
