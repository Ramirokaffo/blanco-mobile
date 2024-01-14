
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';
import 'package:image_to_text/DATA/DataClass/ProductImage.dart';
import 'package:image_to_text/UI/MiniWidget/UniversalSnackBar.dart';


import '../../../StateManager/AddArticlePageState.dart';

void onDeleteImageTap(BuildContext context, Product article, int imageIndex) {
  if (article.images![imageIndex].imageFile != null) {
    article.images!.removeAt(imageIndex);
    refreshAddArticlePageState(context);
    return;
  }
  ProductImage.deleteImageById(article.images![imageIndex].id!).then((value) {
    if (value["status"] == 1) {
      article.images!.removeAt(imageIndex);
      refreshAddArticlePageState(context);
      showUniversalSnackBar(context: context, message: "Image supprimée avec succès !", backgroundColor: Colors.green);
    } else {
      showUniversalSnackBar(context: context, message: "Une erreur s'est produite !", backgroundColor: Colors.red);
    }
  }).onError((error, stackTrace) {
    showUniversalSnackBar(context: context, message: "Une erreur s'est produite !", backgroundColor: Colors.red);
  });

}
