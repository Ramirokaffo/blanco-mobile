


import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';
import '../../../DATA/DataClass/Category.dart';
import '../../../ModalBottomWidget/SelectionModalDropDown.dart';
import '../../../StateManager/AddArticlePageState.dart';

void onArticleCategoryTap(Product article, TextEditingController controller, BuildContext context) async {
  Category category = Category();
  await category.getAllCategory().then((List<Category> listCategory) async {
    List<SelectedListItem> listSelectedListItem = listCategory.map((Category category) {
      return SelectedListItem(name: category.name!, value: category.id.toString());
    }).toList();
  await showSelectionDropDown(controller, context, listSelectedListItem, title: "Catégories d'article").then((value) {
    print("controller.text: ${controller.text}");
    if (controller.text.isNotEmpty) {
      // article.categoryId = Category.allCategoryList.firstWhere((element) => (element.name == controller.text)).id;
      refreshAddArticlePageState(context);
    }
  });
  });
}