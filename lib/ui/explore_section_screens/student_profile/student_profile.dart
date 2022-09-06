import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/vtop_actions.dart';

import '../../../state/vtop_data_state.dart';

class StudentProfilePage extends ConsumerStatefulWidget {
  const StudentProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentProfilePage> createState() => _StudentProfileState();
}

class _StudentProfileState extends ConsumerState<StudentProfilePage> {
  @override
  void initState() {
    final VTOPPageStatus studentProfilePageStatus =
        ref.read(vtopActionsProvider).studentProfilePageStatus;

    if (studentProfilePageStatus != VTOPPageStatus.loaded) {
      final VTOPActions readVTOPActionsProviderValue =
          ref.read(vtopActionsProvider);
      readVTOPActionsProviderValue.studentProfileAllViewAction(
          context: context);
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
      body: RefreshIndicator(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final VTOPPageStatus studentProfilePageStatus = ref.watch(
                vtopActionsProvider
                    .select((value) => value.studentProfilePageStatus));

            final VTOPData vtopData = ref.watch(vtopDataProvider);

            return studentProfilePageStatus == VTOPPageStatus.loaded
                ? ListView(
                    children: [
                      Card(
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Column(
                            children: [
                              DetailLine(
                                parameter1: 'Name',
                                parameter2: vtopData.studentProfile.name,
                              ),
                              const Divider(),
                              DetailLine(
                                parameter1: 'DOB',
                                parameter2: vtopData.studentProfile.dob,
                              ),
                              const Divider(),
                              DetailLine(
                                parameter1: 'Blood Group',
                                parameter2: vtopData.studentProfile.bloodGroup,
                              ),
                              const Divider(),
                              DetailLine(
                                parameter1: 'Roll No.',
                                parameter2: vtopData.studentProfile.rollNo,
                              ),
                              const Divider(),
                              DetailLine(
                                parameter1: 'Application No.',
                                parameter2:
                                    vtopData.studentProfile.applicationNo,
                              ),
                              const Divider(),
                              DetailLine(
                                parameter1: 'Program',
                                parameter2: vtopData.studentProfile.program,
                              ),
                              const Divider(),
                              DetailLine(
                                parameter1: 'Branch',
                                parameter2: vtopData.studentProfile.branch,
                              ),
                              const Divider(),
                              DetailLine(
                                parameter1: 'School',
                                parameter2: vtopData.studentProfile.school,
                              ),
                            ],
                          )),
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
                      );
          },
        ),
        onRefresh: () async {
          final VTOPActions readVTOPActionsProviderValue =
              ref.read(vtopActionsProvider);
          readVTOPActionsProviderValue.studentProfileAllViewAction(
              context: context);
          readVTOPActionsProviderValue.updateStudentProfilePageStatus(
              status: VTOPPageStatus.processing);
        },
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
