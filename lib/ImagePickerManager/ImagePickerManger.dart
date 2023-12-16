
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../UI/MiniWidget/ModalButtonWidget.dart';
import '../MiniFunction/UniversalFooterShown.dart';
import 'ImagePickerMainFunction.dart';


Future<List<XFile?>?>? showModalImagePicker({required BuildContext context, bool isVideo = false, title = "Image du produit", pickOne = false}) async {
  List<XFile?>? imagePick;
  await showTransparentUniversalFooter([
    modalButtonWidget(
        title: "Galerie photo",
        onTap: () async {
          if (!isVideo) {
            await pickImages(ImageSource.gallery, pickOne: pickOne)?.then((image) {
            imagePick = image;
            Navigator.of(context).pop();
          });
          } else {
            await pickOneVideo(ImageSource.gallery)?.then((image) {
              if (image != null) {
                imagePick = [image];
              }
              Navigator.of(context).pop();

        });}
        }),
    modalButtonWidget(
        title: "Appareil photo",
        onTap: () async {
          if (!isVideo) {
            await pickImages(ImageSource.camera, pickOne: pickOne)?.then((image) {
            imagePick = image;
            Navigator.of(context).pop();
          });
          } else {
            await pickOneVideo(ImageSource.camera)?.then((image) {
              if (image != null) {
                imagePick = [image];
              }
              Navigator.of(context).pop();

            });
          }
        })
  ], context, title: title);
  return imagePick;
}
