
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../../../ImagePickerManager/ImagePickerManger.dart';
import '../../../StateManager/AddArticlePageState.dart';

void onChangeImageTap(BuildContext context, Product article, int imageIndex) async {
  await showModalImagePicker(context: context, isVideo: false, title: "Changer l'image", pickOne: true)?.then((List<XFile?>? images) {
    if (images != null && images.isNotEmpty) {
      article.images?[imageIndex].imageFile = images[0];
      refreshAddArticlePageState(context);
    }
  });
}