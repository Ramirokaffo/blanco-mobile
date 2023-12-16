
import 'package:flutter/cupertino.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';


import '../../../StateManager/AddArticlePageState.dart';

void onDeleteImageTap(BuildContext context, Product article, int imageIndex) {
    article.images!.removeAt(imageIndex);
  refreshAddArticlePageState(context);
}
