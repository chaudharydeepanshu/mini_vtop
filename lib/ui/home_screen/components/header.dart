import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, DC",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Have a great day",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            OutlinedButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward),
                    Text("Quick Glance"),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
