
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../../../DATA/DataClass/ProductImage.dart';
import '../../../ImagePickerManager/ImagePickerManger.dart';
import '../../../StateManager/AddArticlePageState.dart';

Future onAddImageTap(BuildContext context, Product article, {isVideo = false}) async {
  await showModalImagePicker(context: context, isVideo: isVideo, pickOne: true, title: isVideo? "Vidéo du produit": "Images du produit")?.then((List<XFile?>? images) {
    if (images != null && images.isNotEmpty) {
        article.images?.addAll(images.map((image) {
          return ProductImage(imageFile: image, path: image?.path);
        }));
        refreshAddArticlePageState(context);
    }
  });
}
