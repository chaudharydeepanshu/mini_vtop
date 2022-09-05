import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_vtop/ui/home_screen/components/explore_section.dart';
import 'package:mini_vtop/ui/home_screen/components/header.dart';
import 'package:mini_vtop/ui/home_screen/components/news_section.dart';
import 'package:mini_vtop/ui/home_screen/components/tools_section.dart';

import '../../state/providers.dart';
import '../../state/user_login_state.dart';
import '../../state/vtop_actions.dart';
import '../login_screen/login.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Portal"),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              ref.listen(
                  userLoginStateProvider.select(
                      (value) => value.loginResponseStatus), (previous, next) {
                //Checking if LoginResponse status is loggedIn and its a new status.
                if (previous != next && next == LoginResponseStatus.loggedOut) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                }
              });

              return IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () {
                  ref.read(userLoginStateProvider).updateLoginStatus(
                      loginStatus: LoginResponseStatus.processing);

                  final VTOPActions readVTOPActionsProviderValue =
                      ref.read(vtopActionsProvider);

                  readVTOPActionsProviderValue.performSignOutAction(
                      context: context);
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
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
      ),
    );
  }
}
