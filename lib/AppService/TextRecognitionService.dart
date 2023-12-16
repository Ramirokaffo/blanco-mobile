import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_text/UI/MiniWidget/ExtractedTextAlert.dart';

import '../ImagePickerManager/ImagePickerManger.dart';


class TextRecognitionService {

  static Future<String> readTextFromImage(BuildContext context, {bool? checkByDefault, String? title}) async {
    String text = "";
    await showModalImagePicker(context: context, isVideo: false, pickOne: true, title: "Source de l'image")?.then((List<XFile?>? images) async {
    if (images != null && images.isNotEmpty) {
      final XFile? pickedFile = images[0];
      if (pickedFile != null) {
        XFile? image = XFile(pickedFile.path);
        final inputImage = InputImage.fromFilePath(image.path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        await textRecognizer.processImage(inputImage).then((RecognizedText recognizedText) async {
          var expectedText = await showDialog(context: context, builder: (context) {
            return ExtractedTextAlert(recognizedText: recognizedText, checkByDefault: checkByDefault, title: title,);
          },);
          print("expectedText: $expectedText");
          textRecognizer.close();
          text = expectedText?? "";
        });
      }
    }
    });
    return text;
  }

}