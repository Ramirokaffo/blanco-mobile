
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_to_text/DATA/DataClass/GrammageType.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';
import '../../../ModalBottomWidget/SelectionModalDropDown.dart';
import '../../../StateManager/AddArticlePageState.dart';

void onProductGrammageTypeTap(Product article, TextEditingController controller, BuildContext context) async {
  GrammageType grammageType = GrammageType();
  await grammageType.getAllRayon().then((List<GrammageType> listCategory) async {
    List<SelectedListItem> listSelectedListItem = listCategory.map((GrammageType grammageType) {
      return SelectedListItem(name: grammageType.name!, value: grammageType.id.toString());
    }).toList();
    await showSelectionDropDown(controller, context, listSelectedListItem, title: "Type de grammage du produit").then((value) {
      if (controller.text.isNotEmpty) {
        // article.categoryId = Category.allCategoryList.firstWhere((element) => (element.name == controller.text)).id;
        refreshAddArticlePageState(context);
      }
    });
  });
}