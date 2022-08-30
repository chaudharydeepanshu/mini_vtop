import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mini_vtop/models/student_profile_model.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/vtop_actions.dart';

import '../../../state/vtop_data_state.dart';

class StudentProfile extends ConsumerStatefulWidget {
  const StudentProfile({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends ConsumerState<StudentProfile> {
  @override
  void initState() {
    final VTOPPageStatus studentProfilePageStatus =
        ref.read(vtopActionsProvider).studentProfilePageStatus;

    if (studentProfilePageStatus != VTOPPageStatus.loaded) {
      final VTOPActions readVTOPActionsProviderValue =
          ref.read(vtopActionsProvider);
      readVTOPActionsProviderValue.callStudentProfileAllView(context: context);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final VTOPPageStatus studentProfilePageStatus = ref.watch(
                  vtopActionsProvider
                      .select((value) => value.studentProfilePageStatus));

              final VTOPData vtopData = ref.watch(vtopDataProvider);

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
                child: studentProfilePageStatus == VTOPPageStatus.loaded
                    ? Column(
                        children: [
                          DetailLine(
                            parameter1: 'Name',
                            parameter2: vtopData.studentProfile.name,
                          ),
                          Divider(),
                          DetailLine(
                            parameter1: 'DOB',
                            parameter2: vtopData.studentProfile.dob,
                          ),
                          Divider(),
                          DetailLine(
                            parameter1: 'Blood Group',
                            parameter2: vtopData.studentProfile.bloodGroup,
                          ),
                          Divider(),
                          DetailLine(
                            parameter1: 'Roll No.',
                            parameter2: vtopData.studentProfile.rollNo,
                          ),
                          Divider(),
                          DetailLine(
                            parameter1: 'Application No.',
                            parameter2: vtopData.studentProfile.applicationNo,
                          ),
                          Divider(),
                          DetailLine(
                            parameter1: 'Program',
                            parameter2: vtopData.studentProfile.program,
                          ),
                          Divider(),
                          DetailLine(
                            parameter1: 'Branch',
                            parameter2: vtopData.studentProfile.branch,
                          ),
                          Divider(),
                          DetailLine(
                            parameter1: 'School',
                            parameter2: vtopData.studentProfile.school,
                          ),
                        ],
                      )
                    : studentProfilePageStatus == VTOPPageStatus.processing
                        ? Center(
                            child: SpinKitThreeBounce(
                              size: 24,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                        : Center(
                            child: Text(
                              "Error",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
              );
            },
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
