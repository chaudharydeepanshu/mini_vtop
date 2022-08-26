import 'package:flutter/material.dart';
import 'package:mini_vtop/ui/home_screen/components/explore_section.dart';
import 'package:mini_vtop/ui/home_screen/components/header.dart';
import 'package:mini_vtop/ui/home_screen/components/news_section.dart';
import 'package:mini_vtop/ui/home_screen/components/tools_section.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Portal"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
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
