

import 'package:flutter/material.dart';

 showUniversalSnackBar({required BuildContext context, required String message, int seconds = 2}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: seconds),
    ),
  );
}
