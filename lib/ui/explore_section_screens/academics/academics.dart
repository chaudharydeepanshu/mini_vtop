import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mini_vtop/ui/header_section_screen/components/gpa_section.dart';

import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/vtop_actions.dart';
import 'package:mini_vtop/state/vtop_data_state.dart';

class Academics extends ConsumerStatefulWidget {
  const Academics({Key? key}) : super(key: key);

  @override
  ConsumerState<Academics> createState() => _AcademicsState();
}

class _AcademicsState extends ConsumerState<Academics> {
  @override
  void initState() {
    final VTOPPageStatus studentGradeHistoryPageStatus =
        ref.read(vtopActionsProvider).studentGradeHistoryPageStatus;

    if (studentGradeHistoryPageStatus != VTOPPageStatus.loaded) {
      final VTOPActions readVTOPActionsProviderValue =
          ref.read(vtopActionsProvider);
      readVTOPActionsProviderValue.callStudentGradeHistory(context: context);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Academics"),
        centerTitle: true,
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final VTOPPageStatus studentGradeHistoryPageStatus = ref.watch(
              vtopActionsProvider
                  .select((value) => value.studentGradeHistoryPageStatus));

          final VTOPData vtopData = ref.watch(vtopDataProvider);

          return studentGradeHistoryPageStatus == VTOPPageStatus.loaded
              ? ListView(
                  children: [
                    CGPASection(
                      currentGPA: vtopData.studentAcademics.cgpa,
                    ),
                  ],
                )
              : studentGradeHistoryPageStatus == VTOPPageStatus.processing
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
    );
  }
}
