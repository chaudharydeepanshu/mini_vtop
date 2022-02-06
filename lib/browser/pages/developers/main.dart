import 'package:flutter/material.dart';
import 'package:mini_vtop/browser/pages/developers/storage_manager.dart';

import 'javascript_console.dart';
import 'network_info.dart';

class DevelopersPage extends StatefulWidget {
  const DevelopersPage({Key? key}) : super(key: key);

  @override
  _DevelopersPageState createState() => _DevelopersPageState();
}

class _DevelopersPageState extends State<DevelopersPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            onTap: (value) {
              FocusScope.of(context).unfocus();
            },
            tabs: const [
              Tab(
                icon: Icon(Icons.code),
                text: "JavaScript Console",
              ),
              Tab(
                icon: Icon(Icons.network_check),
                text: "Network Info",
              ),
              Tab(
                icon: Icon(Icons.storage),
                text: "Storage Manager",
              ),
            ],
          ),
          title: const Text('Developers'),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            JavaScriptConsole(),
            NetworkInfo(),
            StorageManager(),
          ],
        ),
      ),
    );
  }
}
