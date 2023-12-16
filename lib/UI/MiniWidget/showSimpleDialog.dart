import 'package:flutter/material.dart';


void showSimpleDialog(
    {required String title,
      required BuildContext context,
      required String message,
      String? actionText = "OK",
      bool isimgvisible = false,
      Function? onActionTap}) {
  showDialog(
    context: context,
    builder: (BuildContext contex) {
      return AlertDialog(
        scrollable: true,
        title: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            ),
            Divider(color: Theme.of(context).colorScheme.primary,)
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Visibility(
                visible: isimgvisible,
                child: TextButton(
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.white)),
                  child: Text(
                    "Annuler",
                    style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () {
                    Navigator.pop(contex);
                  },
                ),
              ),
              TextButton(
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.white)),
                onPressed: () {
                  onActionTap != null
                      ? onActionTap()
                      : Navigator.pop(contex);
                },
                child: Text(
                  actionText!,
                  style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
