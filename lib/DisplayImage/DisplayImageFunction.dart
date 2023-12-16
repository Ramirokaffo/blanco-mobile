import 'package:flutter/material.dart';

import 'DisplayImage.dart';

void showImage(BuildContext context, String image, bool isLocal, {String title = "Image"}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => DisplaysImage(image: image, islocal: isLocal, title: title),));
}


