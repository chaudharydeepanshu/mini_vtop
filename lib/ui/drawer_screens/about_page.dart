import 'package:flutter/material.dart';
import 'package:minivtop/constants.dart';
import 'package:minivtop/ui/components/link_button.dart';
import 'package:minivtop/ui/components/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        centerTitle: true,
      ),
      body: ListView(
        children: const [
          SizedBox(
            height: 16,
          ),
          AppDescription(),
          SizedBox(
            height: 16,
          ),
          AppBadges(),
          SizedBox(
            height: 16,
          ),
          AppAuthor(),
          SizedBox(
            height: 16,
          ),
          AppContributions(),
          SizedBox(
            height: 16,
          ),
          Credits(),
          SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}

class AppDescription extends StatelessWidget {
  const AppDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      // elevation: 0,
      // shape: RoundedRectangleBorder(
      //   side: BorderSide(
      //     color: Theme.of(context).colorScheme.outline,
      //   ),
      //   borderRadius: const BorderRadius.all(Radius.circular(12)),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Mini VTOP is a flutter project which uses the power of WebView to create a user-friendly unofficial app for the VIT Bhopal University website.",
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class AppBadges extends StatelessWidget {
  const AppBadges({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      // elevation: 0,
      // shape: RoundedRectangleBorder(
      //   side: BorderSide(
      //     color: Theme.of(context).colorScheme.outline,
      //   ),
      //   borderRadius: const BorderRadius.all(Radius.circular(12)),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Image.asset(
                      'assets/open_source.png',
                      height: 100,
                      width: 100,
                    ),
                    Text(
                      "Open Source",
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/no_ads.png',
                      height: 100,
                      width: 100,
                    ),
                    Text(
                      "No ads",
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  LinkButton(urlLabel: "Show Source Code", url: sourceCodeUrl),
            ),
          ],
        ),
      ),
    );
  }
}

class AppAuthor extends StatelessWidget {
  const AppAuthor({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      // elevation: 0,
      // shape: RoundedRectangleBorder(
      //   side: BorderSide(
      //     color: Theme.of(context).colorScheme.outline,
      //   ),
      //   borderRadius: const BorderRadius.all(Radius.circular(12)),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Author",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const Divider(),
            Text(
              "Deepanshu",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinkButton(urlLabel: "LinkedIn", url: authorLinkedInUrl),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "Follow",
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        urlLauncher(authorGithubUrl);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/github_3d_icon.png',
                              height: 30,
                              width: 30,
                            ),
                            const Text('Github Profile'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "⭐ Project",
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        urlLauncher(sourceCodeUrl);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/github_3d_icon.png',
                              height: 30,
                              width: 30,
                            ),
                            const Text('Github Project'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppContributions extends StatelessWidget {
  const AppContributions({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      // elevation: 0,
      // shape: RoundedRectangleBorder(
      //   side: BorderSide(
      //     color: Theme.of(context).colorScheme.outline,
      //   ),
      //   borderRadius: const BorderRadius.all(Radius.circular(12)),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Contributors",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const Divider(),
            Text(
              "App Testers",
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Text(
              "Manas Saini",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinkButton(
                    urlLabel: "Github", url: "https://github.com/ManasSaini03"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Credits extends StatelessWidget {
  const Credits({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      // elevation: 0,
      // shape: RoundedRectangleBorder(
      //   side: BorderSide(
      //     color: Theme.of(context).colorScheme.outline,
      //   ),
      //   borderRadius: const BorderRadius.all(Radius.circular(12)),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Credits",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const Divider(),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Icons by ",
                style: Theme.of(context).textTheme.bodySmall,
                children: const <InlineSpan>[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: LinkButton(
                        urlLabel: "Icons8", url: "https://icons8.com"),
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Animations by ",
                style: Theme.of(context).textTheme.bodySmall,
                children: const <InlineSpan>[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: LinkButton(
                        urlLabel: "Rive Community",
                        url: "https://rive.app/community/"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
