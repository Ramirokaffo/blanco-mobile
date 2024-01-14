

import 'package:flutter/material.dart';

 showUniversalSnackBar({required BuildContext context, required String message,
   Color? backgroundColor, Color? textColor, int seconds = 2}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: textColor),),
      duration: Duration(seconds: seconds),
      backgroundColor: backgroundColor,
    ),
  );
}
