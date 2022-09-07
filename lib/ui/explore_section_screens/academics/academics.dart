import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/ui/header_section_screen/components/gpa_section.dart';

import 'package:mini_vtop/state/providers.dart';
import 'package:mini_vtop/state/vtop_actions.dart';
import 'package:mini_vtop/state/vtop_data_state.dart';
import 'package:mini_vtop/ui/components/page_body_indicators.dart';

import '../../../models/student_academics_model.dart';
import '../../../shared_preferences/preferences.dart';
import '../../components/cached_mode_warning.dart';
import '../../components/empty_content_indicator.dart';

class AcademicsPage extends ConsumerStatefulWidget {
  const AcademicsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AcademicsPage> createState() => _AcademicsState();
}

class _AcademicsState extends ConsumerState<AcademicsPage> {
  @override
  void initState() {
    final VTOPPageStatus studentGradeHistoryPageStatus =
        ref.read(vtopActionsProvider).studentGradeHistoryPageStatus;

    if (studentGradeHistoryPageStatus != VTOPPageStatus.loaded) {
      final VTOPActions readVTOPActionsProviderValue =
          ref.read(vtopActionsProvider);
      readVTOPActionsProviderValue.studentGradeHistoryAction(context: context);
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
      body: RefreshIndicator(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final VTOPPageStatus studentGradeHistoryPageStatus = ref.watch(
                vtopActionsProvider
                    .select((value) => value.studentGradeHistoryPageStatus));

            final bool enableOfflineMode = ref.watch(
                vtopActionsProvider.select((value) => value.enableOfflineMode));

            if (enableOfflineMode == true) {
              final Preferences readPreferencesProviderValue =
                  ref.read(preferencesProvider);
              String? oldHTMLDoc =
                  readPreferencesProviderValue.academicsHTMLDoc;
              final VTOPData readVTOPDataProviderValue =
                  ref.read(vtopDataProvider);
              if (oldHTMLDoc != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  readVTOPDataProviderValue.setStudentAcademics(
                      studentGradeHistoryDocument: oldHTMLDoc);
                });
              }
            }

            return studentGradeHistoryPageStatus == VTOPPageStatus.loaded ||
                    enableOfflineMode
                ? Column(
                    children: const [
                      CachedModeWarning(),
                      Expanded(child: AcademicsBody()),
                    ],
                  )
                : PageBodyIndicators(
                    pageStatus: studentGradeHistoryPageStatus,
                    location: Location.afterHomeScreen);
          },
        ),
        onRefresh: () async {
          final VTOPActions readVTOPActionsProviderValue =
              ref.read(vtopActionsProvider);
          readVTOPActionsProviderValue.updateOfflineModeStatus(mode: false);
          readVTOPActionsProviderValue.studentGradeHistoryAction(
              context: context);
          readVTOPActionsProviderValue.updateStudentProfilePageStatus(
              status: VTOPPageStatus.processing);
        },
      ),
    );
  }
}

class AcademicsBody extends StatelessWidget {
  const AcademicsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final StudentAcademicsModel? studentAcademics = ref
            .watch(vtopDataProvider.select((value) => value.studentAcademics));

        if (studentAcademics != null) {
          return ListView(
            children: [
              CGPASection(
                currentGPA: studentAcademics.cgpa,
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
