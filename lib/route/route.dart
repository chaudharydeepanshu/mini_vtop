import 'package:flutter/material.dart';

import '../ui/connection_screen/connection_page.dart';
import '../ui/explore_section_screens/academics/academics.dart';
import '../ui/explore_section_screens/student_profile/student_profile.dart';
import '../ui/home_screen/components/explore_section.dart';
import '../ui/home_screen/components/news_section.dart';
import '../ui/home_screen/components/tools_section.dart';
import '../ui/home_screen/dashboard_screen.dart';
import '../ui/login_screen/components/forgot_user_id_screen.dart';
import '../ui/login_screen/login_page.dart';

// Route Names
const String connectionPage = 'connection';
const String loginPage = 'login';
const String dashboardPage = 'dashboard';
const String forgotUserIDPage = 'forgotUserID';
const String explorePage = 'explore';
const String newsPage = 'news';
const String toolsPage = 'tools';
const String studentProfilePage = 'StudentProfile';
const String academicsPage = 'Academics';

// Control our page route flow
Route<dynamic> controller(RouteSettings settings) {
  switch (settings.name) {
    case connectionPage:
      return MaterialPageRoute(
          builder: (context) => const ConnectionPage(),
          settings: RouteSettings(name: settings.name));
    case loginPage:
      return MaterialPageRoute(
          builder: (context) => const LoginPage(),
          settings: RouteSettings(name: settings.name));
    case dashboardPage:
      return MaterialPageRoute(
          builder: (context) => const DashboardPage(),
          settings: RouteSettings(name: settings.name));
    case forgotUserIDPage:
      return MaterialPageRoute(
          builder: (context) => const ForgotUserIDPage(),
          settings: RouteSettings(name: settings.name));
    case explorePage:
      return MaterialPageRoute(
          builder: (context) => ExplorePage(
              arguments: settings.arguments as ExplorePageArguments),
          settings: RouteSettings(name: settings.name));
    case newsPage:
      return MaterialPageRoute(
          builder: (context) =>
              NewsPage(arguments: settings.arguments as NewsPageArguments),
          settings: RouteSettings(name: settings.name));
    case toolsPage:
      return MaterialPageRoute(
          builder: (context) =>
              ToolsPage(arguments: settings.arguments as ToolsPageArguments),
          settings: RouteSettings(name: settings.name));
    case studentProfilePage:
      return MaterialPageRoute(
          builder: (context) => const StudentProfilePage(),
          settings: RouteSettings(name: settings.name));
    case academicsPage:
      return MaterialPageRoute(
          builder: (context) => const AcademicsPage(),
          settings: RouteSettings(name: settings.name));

    default:
      throw ('This route name does not exit');
  }
}

/*
Follows https://oflutter.com/organized-navigation-named-route-in-flutter/ route approach.

Use MaterialPageRoute() which uses a default animation. For different one, use PageRouteBuilder() or CupertinoPageRoute().

To Navigate to another page make sure you added a new page to a route.dart file. Then, you can import ‘route/route.dart’ as route; and use route.myNewPage.

To pass an argument while routing between pages consider this example:
Ex: To pass an argument from loginPage to homePage. To do so, first add argument request in HomePage stateless widget. Like so:

home.dart
...
class HomePage extends StatelessWidget {
  final Object argument;
  HomePage({this.argument});

 ....

}
Then, add settings.arguments option to Route<dynamic> controller(RouteSettings settings) for HomePage

route.dart
......

// Control our page route flow
Route<dynamic> controller(RouteSettings settings) {
  switch (settings.name) {
    .....
    case homePage:
      return MaterialPageRoute(builder: (context) => HomePage(arguments: settings.arguments));
    .....

  }
}

.....
Finally, pass any objects e.g text, data when you use Navigator.pushNamed();

home.dart
....

class LoginPage extends StatelessWidget {
....
        child: ElevatedeButton(
         ....
          onPressed: () => Navigator.pushNamed(context, route.homePage, arguments: 'My object As Text'),
         ....
        ),
      ),
    );
  }
}
*/
