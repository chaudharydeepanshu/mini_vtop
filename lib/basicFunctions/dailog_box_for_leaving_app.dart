import 'package:flutter/material.dart';

Future<void> leavingAppDialogBox(
    {String? text,
    List<Widget>? actionButtonsList,
    required BuildContext context}) async {
  await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        contentPadding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF4E8EF2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
          ),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Icon(
                Icons.info,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Text(text ?? "text")],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: actionButtonsList ?? [],
          ),
        ],
      );
    },
  );
}
