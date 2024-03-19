import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minivtop/ui/components/drawer.dart';
import 'package:minivtop/ui/home_screen/components/explore_section.dart';
import 'package:minivtop/ui/home_screen/components/header.dart';
import 'package:minivtop/ui/home_screen/components/news_section.dart';
import 'package:minivtop/ui/home_screen/components/tools_section.dart';

import '../../state/providers.dart';
import '../../state/user_login_state.dart';
import '../../state/vtop_actions.dart';
import 'package:minivtop/route/route.dart' as route;

import '../components/cached_mode_warning.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Student Portal"),
        centerTitle: true,
        actions: const [
          LogoutButton(),
        ],
      ),
      body: const Column(
        children: [
          CachedModeWarning(supportsRefresh: false),
          Expanded(child: DashboardBody()),
        ],
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    bool logoutAttempted = false;
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ref.listen(
            userLoginStateProvider.select((value) => value.loginResponseStatus),
            (previous, next) {
          //Checking if LoginResponse status is loggedIn and its a new status.
          if (previous != next &&
              next == LoginResponseStatus.loggedOut &&
              logoutAttempted) {
            Navigator.pushReplacementNamed(
              context,
              route.loginPage,
            );
            logoutAttempted = false;
          }
        });

        return IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () {
            logoutAttempted = true;

            ref
                .read(userLoginStateProvider)
                .updateLoginStatus(loginStatus: LoginResponseStatus.processing);

            final VTOPActions readVTOPActionsProviderValue =
                ref.read(vtopActionsProvider);

            readVTOPActionsProviderValue.performSignOutAction();
          },
        );
      },
    );
  }
}

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(
          height: 16,
        ),
        HomeHeader(),
        SizedBox(
          height: 16,
        ),
        ExploreSection(),
        SizedBox(
          height: 16,
        ),
        ToolsSection(),
        SizedBox(
          height: 16,
        ),
        NewsSection(),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
