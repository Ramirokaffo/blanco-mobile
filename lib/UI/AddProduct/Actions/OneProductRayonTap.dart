
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';
import 'package:image_to_text/DATA/DataClass/Rayon.dart';
import '../../../DATA/DataClass/Category.dart';
import '../../../ModalBottomWidget/SelectionModalDropDown.dart';
import '../../../StateManager/AddArticlePageState.dart';

void onArticleRayonTap(Product article, TextEditingController controller, BuildContext context) async {
  Rayon rayon = Rayon();
  await rayon.getAllRayon().then((List<Rayon> listCategory) async {
    List<SelectedListItem> listSelectedListItem = listCategory.map((Rayon rayon) {
      return SelectedListItem(name: rayon.name!, value: rayon.id.toString());
    }).toList();
    await showSelectionDropDown(controller, context, listSelectedListItem, title: "Rayon du produit").then((value) {
      if (controller.text.isNotEmpty) {
        // article.categoryId = Category.allCategoryList.firstWhere((element) => (element.name == controller.text)).id;
        refreshAddArticlePageState(context);
      }
    });
  });
}